// rife implemented with ncnn library

#include "rife.h"

#include <algorithm>
#include <vector>
#include "benchmark.h"

#include "rife_preproc.comp.hex.h"
#include "rife_postproc.comp.hex.h"
#include "rife_preproc_tta.comp.hex.h"
#include "rife_postproc_tta.comp.hex.h"
#include "rife_flow_tta_avg.comp.hex.h"
#include "rife_v2_flow_tta_avg.comp.hex.h"
#include "rife_v4_flow_tta_avg.comp.hex.h"
#include "rife_flow_tta_temporal_avg.comp.hex.h"
#include "rife_v2_flow_tta_temporal_avg.comp.hex.h"
#include "rife_v4_flow_tta_temporal_avg.comp.hex.h"
#include "rife_out_tta_temporal_avg.comp.hex.h"
#include "rife_v4_timestep.comp.hex.h"
#include "rife_v4_timestep_tta.comp.hex.h"

#include "rife_ops.h"

DEFINE_LAYER_CREATOR(Warp)

RIFE::RIFE(int gpuid, bool _tta_mode, bool _tta_temporal_mode, bool _uhd_mode, int _num_threads, bool _rife_v2, bool _rife_v4)
{
    vkdev = gpuid == -1 ? 0 : ncnn::get_gpu_device(gpuid);

    rife_preproc = 0;
    rife_postproc = 0;
    rife_flow_tta_avg = 0;
    rife_flow_tta_temporal_avg = 0;
    rife_out_tta_temporal_avg = 0;
    rife_v4_timestep = 0;
    rife_uhd_downscale_image = 0;
    rife_uhd_upscale_flow = 0;
    rife_uhd_double_flow = 0;
    rife_v2_slice_flow = 0;
    tta_mode = _tta_mode;
    tta_temporal_mode = _tta_temporal_mode;
    uhd_mode = _uhd_mode;
    num_threads = _num_threads;
    rife_v2 = _rife_v2;
    rife_v4 = _rife_v4;
}

RIFE::~RIFE()
{
    // cleanup preprocess and postprocess pipeline
    {
        delete rife_preproc;
        delete rife_postproc;
        delete rife_flow_tta_avg;
        delete rife_flow_tta_temporal_avg;
        delete rife_out_tta_temporal_avg;
        delete rife_v4_timestep;
    }

    if (uhd_mode)
    {
        rife_uhd_downscale_image->destroy_pipeline(flownet.opt);
        delete rife_uhd_downscale_image;

        rife_uhd_upscale_flow->destroy_pipeline(flownet.opt);
        delete rife_uhd_upscale_flow;

        rife_uhd_double_flow->destroy_pipeline(flownet.opt);
        delete rife_uhd_double_flow;
    }

    if (rife_v2)
    {
        rife_v2_slice_flow->destroy_pipeline(flownet.opt);
        delete rife_v2_slice_flow;
    }
}

#if _WIN32
static void load_param_model(ncnn::Net& net, const std::wstring& modeldir, const wchar_t* name)
{
    wchar_t parampath[256];
    wchar_t modelpath[256];
    swprintf(parampath, 256, L"%s/%s.param", modeldir.c_str(), name);
    swprintf(modelpath, 256, L"%s/%s.bin", modeldir.c_str(), name);

    {
        FILE* fp = _wfopen(parampath, L"rb");
        if (!fp)
        {
            fwprintf(stderr, L"_wfopen %ls failed\n", parampath);
        }

        net.load_param(fp);

        fclose(fp);
    }
    {
        FILE* fp = _wfopen(modelpath, L"rb");
        if (!fp)
        {
            fwprintf(stderr, L"_wfopen %ls failed\n", modelpath);
        }

        net.load_model(fp);

        fclose(fp);
    }
}
#else
static void load_param_model(ncnn::Net& net, const std::string& modeldir, const char* name)
{
    char parampath[256];
    char modelpath[256];
    sprintf(parampath, "%s/%s.param", modeldir.c_str(), name);
    sprintf(modelpath, "%s/%s.bin", modeldir.c_str(), name);

    net.load_param(parampath);
    net.load_model(modelpath);
}
#endif

#if _WIN32
int RIFE::load(const std::wstring& modeldir)
#else
int RIFE::load(const std::string& modeldir)
#endif
{
    ncnn::Option opt;
    opt.num_threads = num_threads;
    opt.use_vulkan_compute = vkdev ? true : false;
    opt.use_fp16_packed = vkdev ? true : false;
    opt.use_fp16_storage = vkdev ? true : false;
    opt.use_fp16_arithmetic = false;
    opt.use_int8_storage = true;

    flownet.opt = opt;
    contextnet.opt = opt;
    fusionnet.opt = opt;

    flownet.set_vulkan_device(vkdev);
    contextnet.set_vulkan_device(vkdev);
    fusionnet.set_vulkan_device(vkdev);

    flownet.register_custom_layer("rife.Warp", Warp_layer_creator);
    contextnet.register_custom_layer("rife.Warp", Warp_layer_creator);
    fusionnet.register_custom_layer("rife.Warp", Warp_layer_creator);

#if _WIN32
    load_param_model(flownet, modeldir, L"flownet");
    if (!rife_v4)
    {
        load_param_model(contextnet, modeldir, L"contextnet");
        load_param_model(fusionnet, modeldir, L"fusionnet");
    }
#else
    load_param_model(flownet, modeldir, "flownet");
    if (!rife_v4)
    {
        load_param_model(contextnet, modeldir, "contextnet");
        load_param_model(fusionnet, modeldir, "fusionnet");
    }
#endif

    // initialize preprocess and postprocess pipeline
    if (vkdev)
    {
        std::vector<ncnn::vk_specialization_type> specializations(1);
#if _WIN32
        specializations[0].i = 1;
#else
        specializations[0].i = 0;
#endif

        {
            static std::vector<uint32_t> spirv;
            static ncnn::Mutex lock;
            {
                ncnn::MutexLockGuard guard(lock);
                if (spirv.empty())
                {
                    if (tta_mode)
                        compile_spirv_module(rife_preproc_tta_comp_data, sizeof(rife_preproc_tta_comp_data), opt, spirv);
                    else
                        compile_spirv_module(rife_preproc_comp_data, sizeof(rife_preproc_comp_data), opt, spirv);
                }
            }

            rife_preproc = new ncnn::Pipeline(vkdev);
            rife_preproc->set_optimal_local_size_xyz(8, 8, 3);
            rife_preproc->create(spirv.data(), spirv.size() * 4, specializations);
        }

        {
            static std::vector<uint32_t> spirv;
            static ncnn::Mutex lock;
            {
                ncnn::MutexLockGuard guard(lock);
                if (spirv.empty())
                {
                    if (tta_mode)
                        compile_spirv_module(rife_postproc_tta_comp_data, sizeof(rife_postproc_tta_comp_data), opt, spirv);
                    else
                        compile_spirv_module(rife_postproc_comp_data, sizeof(rife_postproc_comp_data), opt, spirv);
                }
            }

            rife_postproc = new ncnn::Pipeline(vkdev);
            rife_postproc->set_optimal_local_size_xyz(8, 8, 3);
            rife_postproc->create(spirv.data(), spirv.size() * 4, specializations);
        }
    }

    if (vkdev && tta_mode)
    {
        static std::vector<uint32_t> spirv;
        static ncnn::Mutex lock;
        {
            ncnn::MutexLockGuard guard(lock);
            if (spirv.empty())
            {
                if (rife_v4)
                {
                    compile_spirv_module(rife_v4_flow_tta_avg_comp_data, sizeof(rife_v4_flow_tta_avg_comp_data), opt, spirv);
                }
                else if (rife_v2)
                {
                    compile_spirv_module(rife_v2_flow_tta_avg_comp_data, sizeof(rife_v2_flow_tta_avg_comp_data), opt, spirv);
                }
                else
                {
                    compile_spirv_module(rife_flow_tta_avg_comp_data, sizeof(rife_flow_tta_avg_comp_data), opt, spirv);
                }
            }
        }

        std::vector<ncnn::vk_specialization_type> specializations(0);

        rife_flow_tta_avg = new ncnn::Pipeline(vkdev);
        rife_flow_tta_avg->set_optimal_local_size_xyz(8, 8, 1);
        rife_flow_tta_avg->create(spirv.data(), spirv.size() * 4, specializations);
    }

    if (vkdev && tta_temporal_mode)
    {
        static std::vector<uint32_t> spirv;
        static ncnn::Mutex lock;
        {
            ncnn::MutexLockGuard guard(lock);
            if (spirv.empty())
            {
                if (rife_v4)
                {
                    compile_spirv_module(rife_v4_flow_tta_temporal_avg_comp_data, sizeof(rife_v4_flow_tta_temporal_avg_comp_data), opt, spirv);
                }
                else if (rife_v2)
                {
                    compile_spirv_module(rife_v2_flow_tta_temporal_avg_comp_data, sizeof(rife_v2_flow_tta_temporal_avg_comp_data), opt, spirv);
                }
                else
                {
                    compile_spirv_module(rife_flow_tta_temporal_avg_comp_data, sizeof(rife_flow_tta_temporal_avg_comp_data), opt, spirv);
                }
            }
        }

        std::vector<ncnn::vk_specialization_type> specializations(0);

        rife_flow_tta_temporal_avg = new ncnn::Pipeline(vkdev);
        rife_flow_tta_temporal_avg->set_optimal_local_size_xyz(8, 8, 1);
        rife_flow_tta_temporal_avg->create(spirv.data(), spirv.size() * 4, specializations);
    }

    if (vkdev && tta_temporal_mode)
    {
        static std::vector<uint32_t> spirv;
        static ncnn::Mutex lock;
        {
            ncnn::MutexLockGuard guard(lock);
            if (spirv.empty())
            {
                compile_spirv_module(rife_out_tta_temporal_avg_comp_data, sizeof(rife_out_tta_temporal_avg_comp_data), opt, spirv);
            }
        }

        std::vector<ncnn::vk_specialization_type> specializations(0);

        rife_out_tta_temporal_avg = new ncnn::Pipeline(vkdev);
        rife_out_tta_temporal_avg->set_optimal_local_size_xyz(8, 8, 1);
        rife_out_tta_temporal_avg->create(spirv.data(), spirv.size() * 4, specializations);
    }

    if (uhd_mode)
    {
        {
            rife_uhd_downscale_image = ncnn::create_layer("Interp");
            rife_uhd_downscale_image->vkdev = vkdev;

            ncnn::ParamDict pd;
            pd.set(0, 2);// bilinear
            pd.set(1, 0.5f);
            pd.set(2, 0.5f);
            rife_uhd_downscale_image->load_param(pd);

            rife_uhd_downscale_image->create_pipeline(opt);
        }
        {
            rife_uhd_upscale_flow = ncnn::create_layer("Interp");
            rife_uhd_upscale_flow->vkdev = vkdev;

            ncnn::ParamDict pd;
            pd.set(0, 2);// bilinear
            pd.set(1, 2.f);
            pd.set(2, 2.f);
            rife_uhd_upscale_flow->load_param(pd);

            rife_uhd_upscale_flow->create_pipeline(opt);
        }
        {
            rife_uhd_double_flow = ncnn::create_layer("BinaryOp");
            rife_uhd_double_flow->vkdev = vkdev;

            ncnn::ParamDict pd;
            pd.set(0, 2);// mul
            pd.set(1, 1);// with_scalar
            pd.set(2, 2.f);// b
            rife_uhd_double_flow->load_param(pd);

            rife_uhd_double_flow->create_pipeline(opt);
        }
    }

    if (rife_v2)
    {
        {
            rife_v2_slice_flow = ncnn::create_layer("Slice");
            rife_v2_slice_flow->vkdev = vkdev;

            ncnn::Mat slice_points(2);
            slice_points.fill<int>(-233);

            ncnn::ParamDict pd;
            pd.set(0, slice_points);
            pd.set(1, 0);// axis

            rife_v2_slice_flow->load_param(pd);

            rife_v2_slice_flow->create_pipeline(opt);
        }
    }

    if (rife_v4)
    {
        if (vkdev)
        {
            static std::vector<uint32_t> spirv;
            static ncnn::Mutex lock;
            {
                ncnn::MutexLockGuard guard(lock);
                if (spirv.empty())
                {
                    if (tta_mode)
                        compile_spirv_module(rife_v4_timestep_tta_comp_data, sizeof(rife_v4_timestep_tta_comp_data), opt, spirv);
                    else
                        compile_spirv_module(rife_v4_timestep_comp_data, sizeof(rife_v4_timestep_comp_data), opt, spirv);
                }
            }

            std::vector<ncnn::vk_specialization_type> specializations;

            rife_v4_timestep = new ncnn::Pipeline(vkdev);
            rife_v4_timestep->set_optimal_local_size_xyz(8, 8, 1);
            rife_v4_timestep->create(spirv.data(), spirv.size() * 4, specializations);
        }
    }

    return 0;
}

int RIFE::process(const ncnn::Mat& in0image, const ncnn::Mat& in1image, float timestep, ncnn::Mat& outimage) const
{
    if (!vkdev)
    {
        // cpu only
        if (rife_v4)
            return process_v4_cpu(in0image, in1image, timestep, outimage);
        else
            return process_cpu(in0image, in1image, timestep, outimage);
    }

    if (rife_v4)
        return process_v4(in0image, in1image, timestep, outimage);

    if (timestep == 0.f)
    {
        outimage = in0image;
        return 0;
    }

    if (timestep == 1.f)
    {
        outimage = in1image;
        return 0;
    }

    const unsigned char* pixel0data = (const unsigned char*)in0image.data;
    const unsigned char* pixel1data = (const unsigned char*)in1image.data;
    const int w = in0image.w;
    const int h = in0image.h;
    const int channels = 3;//in0image.elempack;

//     fprintf(stderr, "%d x %d\n", w, h);

    ncnn::VkAllocator* blob_vkallocator = vkdev->acquire_blob_allocator();
    ncnn::VkAllocator* staging_vkallocator = vkdev->acquire_staging_allocator();

    ncnn::Option opt = flownet.opt;
    opt.blob_vkallocator = blob_vkallocator;
    opt.workspace_vkallocator = blob_vkallocator;
    opt.staging_vkallocator = staging_vkallocator;

    // pad to 32n
    int w_padded = (w + 31) / 32 * 32;
    int h_padded = (h + 31) / 32 * 32;

    const size_t in_out_tile_elemsize = opt.use_fp16_storage ? 2u : 4u;

    ncnn::Mat in0;
    ncnn::Mat in1;
    if (opt.use_fp16_storage && opt.use_int8_storage)
    {
        in0 = ncnn::Mat(w, h, (unsigned char*)pixel0data, (size_t)channels, 1);
        in1 = ncnn::Mat(w, h, (unsigned char*)pixel1data, (size_t)channels, 1);
    }
    else
    {
#if _WIN32
        in0 = ncnn::Mat::from_pixels(pixel0data, ncnn::Mat::PIXEL_BGR2RGB, w, h);
        in1 = ncnn::Mat::from_pixels(pixel1data, ncnn::Mat::PIXEL_BGR2RGB, w, h);
#else
        in0 = ncnn::Mat::from_pixels(pixel0data, ncnn::Mat::PIXEL_RGB, w, h);
        in1 = ncnn::Mat::from_pixels(pixel1data, ncnn::Mat::PIXEL_RGB, w, h);
#endif
    }

    ncnn::VkCompute cmd(vkdev);

    // upload
    ncnn::VkMat in0_gpu;
    ncnn::VkMat in1_gpu;
    {
        cmd.record_clone(in0, in0_gpu, opt);
        cmd.record_clone(in1, in1_gpu, opt);
    }

    ncnn::VkMat out_gpu;

    if (tta_mode)
    {
        // preproc
        ncnn::VkMat in0_gpu_padded[8];
        ncnn::VkMat in1_gpu_padded[8];
        {
            in0_gpu_padded[0].create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in0_gpu_padded[1].create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in0_gpu_padded[2].create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in0_gpu_padded[3].create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in0_gpu_padded[4].create(h_padded, w_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in0_gpu_padded[5].create(h_padded, w_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in0_gpu_padded[6].create(h_padded, w_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in0_gpu_padded[7].create(h_padded, w_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);

            std::vector<ncnn::VkMat> bindings(9);
            bindings[0] = in0_gpu;
            bindings[1] = in0_gpu_padded[0];
            bindings[2] = in0_gpu_padded[1];
            bindings[3] = in0_gpu_padded[2];
            bindings[4] = in0_gpu_padded[3];
            bindings[5] = in0_gpu_padded[4];
            bindings[6] = in0_gpu_padded[5];
            bindings[7] = in0_gpu_padded[6];
            bindings[8] = in0_gpu_padded[7];

            std::vector<ncnn::vk_constant_type> constants(6);
            constants[0].i = in0_gpu.w;
            constants[1].i = in0_gpu.h;
            constants[2].i = in0_gpu.cstep;
            constants[3].i = in0_gpu_padded[0].w;
            constants[4].i = in0_gpu_padded[0].h;
            constants[5].i = in0_gpu_padded[0].cstep;

            cmd.record_pipeline(rife_preproc, bindings, constants, in0_gpu_padded[0]);
        }
        {
            in1_gpu_padded[0].create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in1_gpu_padded[1].create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in1_gpu_padded[2].create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in1_gpu_padded[3].create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in1_gpu_padded[4].create(h_padded, w_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in1_gpu_padded[5].create(h_padded, w_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in1_gpu_padded[6].create(h_padded, w_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in1_gpu_padded[7].create(h_padded, w_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);

            std::vector<ncnn::VkMat> bindings(9);
            bindings[0] = in1_gpu;
            bindings[1] = in1_gpu_padded[0];
            bindings[2] = in1_gpu_padded[1];
            bindings[3] = in1_gpu_padded[2];
            bindings[4] = in1_gpu_padded[3];
            bindings[5] = in1_gpu_padded[4];
            bindings[6] = in1_gpu_padded[5];
            bindings[7] = in1_gpu_padded[6];
            bindings[8] = in1_gpu_padded[7];

            std::vector<ncnn::vk_constant_type> constants(6);
            constants[0].i = in1_gpu.w;
            constants[1].i = in1_gpu.h;
            constants[2].i = in1_gpu.cstep;
            constants[3].i = in1_gpu_padded[0].w;
            constants[4].i = in1_gpu_padded[0].h;
            constants[5].i = in1_gpu_padded[0].cstep;

            cmd.record_pipeline(rife_preproc, bindings, constants, in1_gpu_padded[0]);
        }

        ncnn::VkMat flow[8];
        for (int ti = 0; ti < 8; ti++)
        {
            // flownet
            ncnn::Extractor ex = flownet.create_extractor();
            ex.set_blob_vkallocator(blob_vkallocator);
            ex.set_workspace_vkallocator(blob_vkallocator);
            ex.set_staging_vkallocator(staging_vkallocator);

            if (uhd_mode)
            {
                ncnn::VkMat in0_gpu_padded_downscaled;
                ncnn::VkMat in1_gpu_padded_downscaled;
                rife_uhd_downscale_image->forward(in0_gpu_padded[ti], in0_gpu_padded_downscaled, cmd, opt);
                rife_uhd_downscale_image->forward(in1_gpu_padded[ti], in1_gpu_padded_downscaled, cmd, opt);

                ex.input("input0", in0_gpu_padded_downscaled);
                ex.input("input1", in1_gpu_padded_downscaled);

                ncnn::VkMat flow_downscaled;
                ex.extract("flow", flow_downscaled, cmd);

                ncnn::VkMat flow_half;
                rife_uhd_upscale_flow->forward(flow_downscaled, flow_half, cmd, opt);

                rife_uhd_double_flow->forward(flow_half, flow[ti], cmd, opt);
            }
            else
            {
                ex.input("input0", in0_gpu_padded[ti]);
                ex.input("input1", in1_gpu_padded[ti]);
                ex.extract("flow", flow[ti], cmd);
            }
        }

        ncnn::VkMat flow_reversed[8];
        if (tta_temporal_mode)
        {
            for (int ti = 0; ti < 8; ti++)
            {
                // flownet
                ncnn::Extractor ex = flownet.create_extractor();
                ex.set_blob_vkallocator(blob_vkallocator);
                ex.set_workspace_vkallocator(blob_vkallocator);
                ex.set_staging_vkallocator(staging_vkallocator);

                if (uhd_mode)
                {
                    ncnn::VkMat in0_gpu_padded_downscaled;
                    ncnn::VkMat in1_gpu_padded_downscaled;
                    rife_uhd_downscale_image->forward(in0_gpu_padded[ti], in0_gpu_padded_downscaled, cmd, opt);
                    rife_uhd_downscale_image->forward(in1_gpu_padded[ti], in1_gpu_padded_downscaled, cmd, opt);

                    ex.input("input0", in1_gpu_padded_downscaled);
                    ex.input("input1", in0_gpu_padded_downscaled);

                    ncnn::VkMat flow_downscaled;
                    ex.extract("flow", flow_downscaled, cmd);

                    ncnn::VkMat flow_half;
                    rife_uhd_upscale_flow->forward(flow_downscaled, flow_half, cmd, opt);

                    rife_uhd_double_flow->forward(flow_half, flow_reversed[ti], cmd, opt);
                }
                else
                {
                    ex.input("input0", in1_gpu_padded[ti]);
                    ex.input("input1", in0_gpu_padded[ti]);
                    ex.extract("flow", flow_reversed[ti], cmd);
                }
            }
        }

        // avg flow
        ncnn::VkMat flow0[8];
        ncnn::VkMat flow1[8];
        {
            std::vector<ncnn::VkMat> bindings(8);
            bindings[0] = flow[0];
            bindings[1] = flow[1];
            bindings[2] = flow[2];
            bindings[3] = flow[3];
            bindings[4] = flow[4];
            bindings[5] = flow[5];
            bindings[6] = flow[6];
            bindings[7] = flow[7];

            std::vector<ncnn::vk_constant_type> constants(3);
            constants[0].i = flow[0].w;
            constants[1].i = flow[0].h;
            constants[2].i = flow[0].cstep;

            ncnn::VkMat dispatcher;
            dispatcher.w = flow[0].w;
            dispatcher.h = flow[0].h;
            dispatcher.c = 1;
            cmd.record_pipeline(rife_flow_tta_avg, bindings, constants, dispatcher);
        }

        if (tta_temporal_mode)
        {
            std::vector<ncnn::VkMat> bindings(8);
            bindings[0] = flow_reversed[0];
            bindings[1] = flow_reversed[1];
            bindings[2] = flow_reversed[2];
            bindings[3] = flow_reversed[3];
            bindings[4] = flow_reversed[4];
            bindings[5] = flow_reversed[5];
            bindings[6] = flow_reversed[6];
            bindings[7] = flow_reversed[7];

            std::vector<ncnn::vk_constant_type> constants(3);
            constants[0].i = flow_reversed[0].w;
            constants[1].i = flow_reversed[0].h;
            constants[2].i = flow_reversed[0].cstep;

            ncnn::VkMat dispatcher;
            dispatcher.w = flow_reversed[0].w;
            dispatcher.h = flow_reversed[0].h;
            dispatcher.c = 1;
            cmd.record_pipeline(rife_flow_tta_avg, bindings, constants, dispatcher);

            // merge flow and flow_reversed
            for (int ti = 0; ti < 8; ti++)
            {
                std::vector<ncnn::VkMat> bindings(2);
                bindings[0] = flow[ti];
                bindings[1] = flow_reversed[ti];

                std::vector<ncnn::vk_constant_type> constants(3);
                constants[0].i = flow[ti].w;
                constants[1].i = flow[ti].h;
                constants[2].i = flow[ti].cstep;

                ncnn::VkMat dispatcher;
                dispatcher.w = flow[ti].w;
                dispatcher.h = flow[ti].h;
                dispatcher.c = 1;

                cmd.record_pipeline(rife_flow_tta_temporal_avg, bindings, constants, dispatcher);
            }
        }

        if (rife_v2)
        {
            for (int ti = 0; ti < 8; ti++)
            {
                std::vector<ncnn::VkMat> inputs(1);
                inputs[0] = flow[ti];
                std::vector<ncnn::VkMat> outputs(2);
                rife_v2_slice_flow->forward(inputs, outputs, cmd, opt);
                flow0[ti] = outputs[0];
                flow1[ti] = outputs[1];
            }
        }

        ncnn::VkMat out_gpu_padded[8];
        for (int ti = 0; ti < 8; ti++)
        {
            // contextnet
            ncnn::VkMat ctx0[4];
            ncnn::VkMat ctx1[4];
            {
                ncnn::Extractor ex = contextnet.create_extractor();
                ex.set_blob_vkallocator(blob_vkallocator);
                ex.set_workspace_vkallocator(blob_vkallocator);
                ex.set_staging_vkallocator(staging_vkallocator);

                ex.input("input.1", in0_gpu_padded[ti]);
                if (rife_v2)
                {
                    ex.input("flow.0", flow0[ti]);
                }
                else
                {
                    ex.input("flow.0", flow[ti]);
                }
                ex.extract("f1", ctx0[0], cmd);
                ex.extract("f2", ctx0[1], cmd);
                ex.extract("f3", ctx0[2], cmd);
                ex.extract("f4", ctx0[3], cmd);
            }
            {
                ncnn::Extractor ex = contextnet.create_extractor();
                ex.set_blob_vkallocator(blob_vkallocator);
                ex.set_workspace_vkallocator(blob_vkallocator);
                ex.set_staging_vkallocator(staging_vkallocator);

                ex.input("input.1", in1_gpu_padded[ti]);
                if (rife_v2)
                {
                    ex.input("flow.0", flow1[ti]);
                }
                else
                {
                    ex.input("flow.1", flow[ti]);
                }
                ex.extract("f1", ctx1[0], cmd);
                ex.extract("f2", ctx1[1], cmd);
                ex.extract("f3", ctx1[2], cmd);
                ex.extract("f4", ctx1[3], cmd);
            }

            // fusionnet
            {
                ncnn::Extractor ex = fusionnet.create_extractor();
                ex.set_blob_vkallocator(blob_vkallocator);
                ex.set_workspace_vkallocator(blob_vkallocator);
                ex.set_staging_vkallocator(staging_vkallocator);

                ex.input("img0", in0_gpu_padded[ti]);
                ex.input("img1", in1_gpu_padded[ti]);
                ex.input("flow", flow[ti]);
                ex.input("3", ctx0[0]);
                ex.input("4", ctx0[1]);
                ex.input("5", ctx0[2]);
                ex.input("6", ctx0[3]);
                ex.input("7", ctx1[0]);
                ex.input("8", ctx1[1]);
                ex.input("9", ctx1[2]);
                ex.input("10", ctx1[3]);

                // save some memory
                if (!tta_temporal_mode)
                {
                    if (ti == 0)
                    {
                        in0_gpu.release();
                        in1_gpu.release();
                    }
                    else
                    {
                        in0_gpu_padded[ti - 1].release();
                        in1_gpu_padded[ti - 1].release();
                    }
                    ctx0[0].release();
                    ctx0[1].release();
                    ctx0[2].release();
                    ctx0[3].release();
                    ctx1[0].release();
                    ctx1[1].release();
                    ctx1[2].release();
                    ctx1[3].release();
                }
                if (ti != 0)
                {
                    flow[ti - 1].release();
                }

                ex.extract("output", out_gpu_padded[ti], cmd);
            }

            if (tta_temporal_mode)
            {
                // fusionnet
                ncnn::VkMat out_gpu_padded_reversed;
                {
                    ncnn::Extractor ex = fusionnet.create_extractor();
                    ex.set_blob_vkallocator(blob_vkallocator);
                    ex.set_workspace_vkallocator(blob_vkallocator);
                    ex.set_staging_vkallocator(staging_vkallocator);

                    ex.input("img0", in1_gpu_padded[ti]);
                    ex.input("img1", in0_gpu_padded[ti]);
                    ex.input("flow", flow_reversed[ti]);
                    ex.input("3", ctx1[0]);
                    ex.input("4", ctx1[1]);
                    ex.input("5", ctx1[2]);
                    ex.input("6", ctx1[3]);
                    ex.input("7", ctx0[0]);
                    ex.input("8", ctx0[1]);
                    ex.input("9", ctx0[2]);
                    ex.input("10", ctx0[3]);

                    // save some memory
                    if (ti == 0)
                    {
                        in0_gpu.release();
                        in1_gpu.release();
                    }
                    else
                    {
                        in0_gpu_padded[ti - 1].release();
                        in1_gpu_padded[ti - 1].release();
                        flow_reversed[ti - 1].release();
                    }
                    ctx0[0].release();
                    ctx0[1].release();
                    ctx0[2].release();
                    ctx0[3].release();
                    ctx1[0].release();
                    ctx1[1].release();
                    ctx1[2].release();
                    ctx1[3].release();

                    ex.extract("output", out_gpu_padded_reversed, cmd);
                }

                // merge output
                {
                    std::vector<ncnn::VkMat> bindings(2);
                    bindings[0] = out_gpu_padded[ti];
                    bindings[1] = out_gpu_padded_reversed;

                    std::vector<ncnn::vk_constant_type> constants(3);
                    constants[0].i = out_gpu_padded[ti].w;
                    constants[1].i = out_gpu_padded[ti].h;
                    constants[2].i = out_gpu_padded[ti].cstep;

                    ncnn::VkMat dispatcher;
                    dispatcher.w = out_gpu_padded[ti].w;
                    dispatcher.h = out_gpu_padded[ti].h;
                    dispatcher.c = 3;
                    cmd.record_pipeline(rife_out_tta_temporal_avg, bindings, constants, dispatcher);
                }
            }
        }

        if (opt.use_fp16_storage && opt.use_int8_storage)
        {
            out_gpu.create(w, h, (size_t)channels, 1, blob_vkallocator);
        }
        else
        {
            out_gpu.create(w, h, channels, (size_t)4u, 1, blob_vkallocator);
        }

        // postproc
        {
            std::vector<ncnn::VkMat> bindings(9);
            bindings[0] = out_gpu_padded[0];
            bindings[1] = out_gpu_padded[1];
            bindings[2] = out_gpu_padded[2];
            bindings[3] = out_gpu_padded[3];
            bindings[4] = out_gpu_padded[4];
            bindings[5] = out_gpu_padded[5];
            bindings[6] = out_gpu_padded[6];
            bindings[7] = out_gpu_padded[7];
            bindings[8] = out_gpu;

            std::vector<ncnn::vk_constant_type> constants(6);
            constants[0].i = out_gpu_padded[0].w;
            constants[1].i = out_gpu_padded[0].h;
            constants[2].i = out_gpu_padded[0].cstep;
            constants[3].i = out_gpu.w;
            constants[4].i = out_gpu.h;
            constants[5].i = out_gpu.cstep;

            cmd.record_pipeline(rife_postproc, bindings, constants, out_gpu);
        }
    }
    else
    {
        // preproc
        ncnn::VkMat in0_gpu_padded;
        ncnn::VkMat in1_gpu_padded;
        {
            in0_gpu_padded.create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);

            std::vector<ncnn::VkMat> bindings(2);
            bindings[0] = in0_gpu;
            bindings[1] = in0_gpu_padded;

            std::vector<ncnn::vk_constant_type> constants(6);
            constants[0].i = in0_gpu.w;
            constants[1].i = in0_gpu.h;
            constants[2].i = in0_gpu.cstep;
            constants[3].i = in0_gpu_padded.w;
            constants[4].i = in0_gpu_padded.h;
            constants[5].i = in0_gpu_padded.cstep;

            cmd.record_pipeline(rife_preproc, bindings, constants, in0_gpu_padded);
        }
        {
            in1_gpu_padded.create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);

            std::vector<ncnn::VkMat> bindings(2);
            bindings[0] = in1_gpu;
            bindings[1] = in1_gpu_padded;

            std::vector<ncnn::vk_constant_type> constants(6);
            constants[0].i = in1_gpu.w;
            constants[1].i = in1_gpu.h;
            constants[2].i = in1_gpu.cstep;
            constants[3].i = in1_gpu_padded.w;
            constants[4].i = in1_gpu_padded.h;
            constants[5].i = in1_gpu_padded.cstep;

            cmd.record_pipeline(rife_preproc, bindings, constants, in1_gpu_padded);
        }

        // flownet
        ncnn::VkMat flow;
        ncnn::VkMat flow0;
        ncnn::VkMat flow1;
        {
            ncnn::Extractor ex = flownet.create_extractor();
            ex.set_blob_vkallocator(blob_vkallocator);
            ex.set_workspace_vkallocator(blob_vkallocator);
            ex.set_staging_vkallocator(staging_vkallocator);

            if (uhd_mode)
            {
                ncnn::VkMat in0_gpu_padded_downscaled;
                ncnn::VkMat in1_gpu_padded_downscaled;
                rife_uhd_downscale_image->forward(in0_gpu_padded, in0_gpu_padded_downscaled, cmd, opt);
                rife_uhd_downscale_image->forward(in1_gpu_padded, in1_gpu_padded_downscaled, cmd, opt);

                ex.input("input0", in0_gpu_padded_downscaled);
                ex.input("input1", in1_gpu_padded_downscaled);

                ncnn::VkMat flow_downscaled;
                ex.extract("flow", flow_downscaled, cmd);

                ncnn::VkMat flow_half;
                rife_uhd_upscale_flow->forward(flow_downscaled, flow_half, cmd, opt);

                rife_uhd_double_flow->forward(flow_half, flow, cmd, opt);
            }
            else
            {
                ex.input("input0", in0_gpu_padded);
                ex.input("input1", in1_gpu_padded);
                ex.extract("flow", flow, cmd);
            }
        }

        ncnn::VkMat flow_reversed;
        if (tta_temporal_mode)
        {
            // flownet
            ncnn::Extractor ex = flownet.create_extractor();
            ex.set_blob_vkallocator(blob_vkallocator);
            ex.set_workspace_vkallocator(blob_vkallocator);
            ex.set_staging_vkallocator(staging_vkallocator);

            if (uhd_mode)
            {
                ncnn::VkMat in0_gpu_padded_downscaled;
                ncnn::VkMat in1_gpu_padded_downscaled;
                rife_uhd_downscale_image->forward(in0_gpu_padded, in0_gpu_padded_downscaled, cmd, opt);
                rife_uhd_downscale_image->forward(in1_gpu_padded, in1_gpu_padded_downscaled, cmd, opt);

                ex.input("input0", in1_gpu_padded_downscaled);
                ex.input("input1", in0_gpu_padded_downscaled);

                ncnn::VkMat flow_downscaled;
                ex.extract("flow", flow_downscaled, cmd);

                ncnn::VkMat flow_half;
                rife_uhd_upscale_flow->forward(flow_downscaled, flow_half, cmd, opt);

                rife_uhd_double_flow->forward(flow_half, flow_reversed, cmd, opt);
            }
            else
            {
                ex.input("input0", in1_gpu_padded);
                ex.input("input1", in0_gpu_padded);
                ex.extract("flow", flow_reversed, cmd);
            }

            // merge flow and flow_reversed
            {
                std::vector<ncnn::VkMat> bindings(2);
                bindings[0] = flow;
                bindings[1] = flow_reversed;

                std::vector<ncnn::vk_constant_type> constants(3);
                constants[0].i = flow.w;
                constants[1].i = flow.h;
                constants[2].i = flow.cstep;

                ncnn::VkMat dispatcher;
                dispatcher.w = flow.w;
                dispatcher.h = flow.h;
                dispatcher.c = 1;

                cmd.record_pipeline(rife_flow_tta_temporal_avg, bindings, constants, dispatcher);
            }
        }

        if (rife_v2)
        {
            std::vector<ncnn::VkMat> inputs(1);
            inputs[0] = flow;
            std::vector<ncnn::VkMat> outputs(2);
            rife_v2_slice_flow->forward(inputs, outputs, cmd, opt);
            flow0 = outputs[0];
            flow1 = outputs[1];
        }

        // contextnet
        ncnn::VkMat ctx0[4];
        ncnn::VkMat ctx1[4];
        {
            ncnn::Extractor ex = contextnet.create_extractor();
            ex.set_blob_vkallocator(blob_vkallocator);
            ex.set_workspace_vkallocator(blob_vkallocator);
            ex.set_staging_vkallocator(staging_vkallocator);

            ex.input("input.1", in0_gpu_padded);
            if (rife_v2)
            {
                ex.input("flow.0", flow0);
            }
            else
            {
                ex.input("flow.0", flow);
            }
            ex.extract("f1", ctx0[0], cmd);
            ex.extract("f2", ctx0[1], cmd);
            ex.extract("f3", ctx0[2], cmd);
            ex.extract("f4", ctx0[3], cmd);
        }
        {
            ncnn::Extractor ex = contextnet.create_extractor();
            ex.set_blob_vkallocator(blob_vkallocator);
            ex.set_workspace_vkallocator(blob_vkallocator);
            ex.set_staging_vkallocator(staging_vkallocator);

            ex.input("input.1", in1_gpu_padded);
            if (rife_v2)
            {
                ex.input("flow.0", flow1);
            }
            else
            {
                ex.input("flow.1", flow);
            }
            ex.extract("f1", ctx1[0], cmd);
            ex.extract("f2", ctx1[1], cmd);
            ex.extract("f3", ctx1[2], cmd);
            ex.extract("f4", ctx1[3], cmd);
        }

        // fusionnet
        ncnn::VkMat out_gpu_padded;
        {
            ncnn::Extractor ex = fusionnet.create_extractor();
            ex.set_blob_vkallocator(blob_vkallocator);
            ex.set_workspace_vkallocator(blob_vkallocator);
            ex.set_staging_vkallocator(staging_vkallocator);

            ex.input("img0", in0_gpu_padded);
            ex.input("img1", in1_gpu_padded);
            ex.input("flow", flow);
            ex.input("3", ctx0[0]);
            ex.input("4", ctx0[1]);
            ex.input("5", ctx0[2]);
            ex.input("6", ctx0[3]);
            ex.input("7", ctx1[0]);
            ex.input("8", ctx1[1]);
            ex.input("9", ctx1[2]);
            ex.input("10", ctx1[3]);

            if (!tta_temporal_mode)
            {
                // save some memory
                in0_gpu.release();
                in1_gpu.release();
                ctx0[0].release();
                ctx0[1].release();
                ctx0[2].release();
                ctx0[3].release();
                ctx1[0].release();
                ctx1[1].release();
                ctx1[2].release();
                ctx1[3].release();
            }
            flow.release();

            ex.extract("output", out_gpu_padded, cmd);
        }

        if (tta_temporal_mode)
        {
            // fusionnet
            ncnn::VkMat out_gpu_padded_reversed;
            {
                ncnn::Extractor ex = fusionnet.create_extractor();
                ex.set_blob_vkallocator(blob_vkallocator);
                ex.set_workspace_vkallocator(blob_vkallocator);
                ex.set_staging_vkallocator(staging_vkallocator);

                ex.input("img0", in1_gpu_padded);
                ex.input("img1", in0_gpu_padded);
                ex.input("flow", flow_reversed);
                ex.input("3", ctx1[0]);
                ex.input("4", ctx1[1]);
                ex.input("5", ctx1[2]);
                ex.input("6", ctx1[3]);
                ex.input("7", ctx0[0]);
                ex.input("8", ctx0[1]);
                ex.input("9", ctx0[2]);
                ex.input("10", ctx0[3]);

                // save some memory
                in0_gpu.release();
                in1_gpu.release();
                ctx0[0].release();
                ctx0[1].release();
                ctx0[2].release();
                ctx0[3].release();
                ctx1[0].release();
                ctx1[1].release();
                ctx1[2].release();
                ctx1[3].release();
                flow_reversed.release();

                ex.extract("output", out_gpu_padded_reversed, cmd);
            }

            // merge output
            {
                std::vector<ncnn::VkMat> bindings(2);
                bindings[0] = out_gpu_padded;
                bindings[1] = out_gpu_padded_reversed;

                std::vector<ncnn::vk_constant_type> constants(3);
                constants[0].i = out_gpu_padded.w;
                constants[1].i = out_gpu_padded.h;
                constants[2].i = out_gpu_padded.cstep;

                ncnn::VkMat dispatcher;
                dispatcher.w = out_gpu_padded.w;
                dispatcher.h = out_gpu_padded.h;
                dispatcher.c = 3;
                cmd.record_pipeline(rife_out_tta_temporal_avg, bindings, constants, dispatcher);
            }
        }

        if (opt.use_fp16_storage && opt.use_int8_storage)
        {
            out_gpu.create(w, h, (size_t)channels, 1, blob_vkallocator);
        }
        else
        {
            out_gpu.create(w, h, channels, (size_t)4u, 1, blob_vkallocator);
        }

        // postproc
        {
            std::vector<ncnn::VkMat> bindings(2);
            bindings[0] = out_gpu_padded;
            bindings[1] = out_gpu;

            std::vector<ncnn::vk_constant_type> constants(6);
            constants[0].i = out_gpu_padded.w;
            constants[1].i = out_gpu_padded.h;
            constants[2].i = out_gpu_padded.cstep;
            constants[3].i = out_gpu.w;
            constants[4].i = out_gpu.h;
            constants[5].i = out_gpu.cstep;

            cmd.record_pipeline(rife_postproc, bindings, constants, out_gpu);
        }
    }

    // download
    {
        ncnn::Mat out;

        if (opt.use_fp16_storage && opt.use_int8_storage)
        {
            out = ncnn::Mat(out_gpu.w, out_gpu.h, (unsigned char*)outimage.data, (size_t)channels, 1);
        }

        cmd.record_clone(out_gpu, out, opt);

        cmd.submit_and_wait();

        if (!(opt.use_fp16_storage && opt.use_int8_storage))
        {
#if _WIN32
            out.to_pixels((unsigned char*)outimage.data, ncnn::Mat::PIXEL_RGB2BGR);
#else
            out.to_pixels((unsigned char*)outimage.data, ncnn::Mat::PIXEL_RGB);
#endif
        }
    }

    vkdev->reclaim_blob_allocator(blob_vkallocator);
    vkdev->reclaim_staging_allocator(staging_vkallocator);

    return 0;
}

int RIFE::process_cpu(const ncnn::Mat& in0image, const ncnn::Mat& in1image, float timestep, ncnn::Mat& outimage) const
{
    if (timestep == 0.f)
    {
        outimage = in0image;
        return 0;
    }

    if (timestep == 1.f)
    {
        outimage = in1image;
        return 0;
    }

    const unsigned char* pixel0data = (const unsigned char*)in0image.data;
    const unsigned char* pixel1data = (const unsigned char*)in1image.data;
    const int w = in0image.w;
    const int h = in0image.h;
    const int channels = 3;//in0image.elempack;

//     fprintf(stderr, "%d x %d\n", w, h);

    ncnn::Option opt = flownet.opt;

    // pad to 32n
    int w_padded = (w + 31) / 32 * 32;
    int h_padded = (h + 31) / 32 * 32;

    ncnn::Mat in0;
    ncnn::Mat in1;
    {
#if _WIN32
        in0 = ncnn::Mat::from_pixels(pixel0data, ncnn::Mat::PIXEL_BGR2RGB, w, h);
        in1 = ncnn::Mat::from_pixels(pixel1data, ncnn::Mat::PIXEL_BGR2RGB, w, h);
#else
        in0 = ncnn::Mat::from_pixels(pixel0data, ncnn::Mat::PIXEL_RGB, w, h);
        in1 = ncnn::Mat::from_pixels(pixel1data, ncnn::Mat::PIXEL_RGB, w, h);
#endif
    }

    ncnn::Mat out;

    if (tta_mode)
    {
        // preproc and border padding
        ncnn::Mat in0_padded[8];
        ncnn::Mat in1_padded[8];
        {
            in0_padded[0].create(w_padded, h_padded, 3);
            for (int q = 0; q < 3; q++)
            {
                float* outptr = in0_padded[0].channel(q);

                int i = 0;
                for (; i < h; i++)
                {
                    const float* ptr = in0.channel(q).row(i);

                    int j = 0;
                    for (; j < w; j++)
                    {
                        *outptr++ = *ptr++ * (1 / 255.f);
                    }
                    for (; j < w_padded; j++)
                    {
                        *outptr++ = 0.f;
                    }
                }
                for (; i < h_padded; i++)
                {
                    for (int j = 0; j < w_padded; j++)
                    {
                        *outptr++ = 0.f;
                    }
                }
            }
        }
        {
            in1_padded[0].create(w_padded, h_padded, 3);
            for (int q = 0; q < 3; q++)
            {
                float* outptr = in1_padded[0].channel(q);

                int i = 0;
                for (; i < h; i++)
                {
                    const float* ptr = in1.channel(q).row(i);

                    int j = 0;
                    for (; j < w; j++)
                    {
                        *outptr++ = *ptr++ * (1 / 255.f);
                    }
                    for (; j < w_padded; j++)
                    {
                        *outptr++ = 0.f;
                    }
                }
                for (; i < h_padded; i++)
                {
                    for (int j = 0; j < w_padded; j++)
                    {
                        *outptr++ = 0.f;
                    }
                }
            }
        }

        // the other 7 directions
        {
            in0_padded[1].create(w_padded, h_padded, 3);
            in0_padded[2].create(w_padded, h_padded, 3);
            in0_padded[3].create(w_padded, h_padded, 3);
            in0_padded[4].create(h_padded, w_padded, 3);
            in0_padded[5].create(h_padded, w_padded, 3);
            in0_padded[6].create(h_padded, w_padded, 3);
            in0_padded[7].create(h_padded, w_padded, 3);

            for (int q = 0; q < 3; q++)
            {
                const ncnn::Mat in0_padded_0 = in0_padded[0].channel(q);
                ncnn::Mat in0_padded_1 = in0_padded[1].channel(q);
                ncnn::Mat in0_padded_2 = in0_padded[2].channel(q);
                ncnn::Mat in0_padded_3 = in0_padded[3].channel(q);
                ncnn::Mat in0_padded_4 = in0_padded[4].channel(q);
                ncnn::Mat in0_padded_5 = in0_padded[5].channel(q);
                ncnn::Mat in0_padded_6 = in0_padded[6].channel(q);
                ncnn::Mat in0_padded_7 = in0_padded[7].channel(q);

                for (int i = 0; i < h_padded; i++)
                {
                    const float* outptr0 = in0_padded_0.row(i);
                    float* outptr1 = in0_padded_1.row(i) + w_padded - 1;
                    float* outptr2 = in0_padded_2.row(h_padded - 1 - i) + w_padded - 1;
                    float* outptr3 = in0_padded_3.row(h_padded - 1 - i);

                    for (int j = 0; j < w_padded; j++)
                    {
                        float* outptr4 = in0_padded_4.row(j) + i;
                        float* outptr5 = in0_padded_5.row(j) + h_padded - 1 - i;
                        float* outptr6 = in0_padded_6.row(w_padded - 1 - j) + h_padded - 1 - i;
                        float* outptr7 = in0_padded_7.row(w_padded - 1 - j) + i;

                        float v = *outptr0++;

                        *outptr1-- = v;
                        *outptr2-- = v;
                        *outptr3++ = v;
                        *outptr4 = v;
                        *outptr5 = v;
                        *outptr6 = v;
                        *outptr7 = v;
                    }
                }
            }
        }
        {
            in1_padded[1].create(w_padded, h_padded, 3);
            in1_padded[2].create(w_padded, h_padded, 3);
            in1_padded[3].create(w_padded, h_padded, 3);
            in1_padded[4].create(h_padded, w_padded, 3);
            in1_padded[5].create(h_padded, w_padded, 3);
            in1_padded[6].create(h_padded, w_padded, 3);
            in1_padded[7].create(h_padded, w_padded, 3);

            for (int q = 0; q < 3; q++)
            {
                const ncnn::Mat in1_padded_0 = in1_padded[0].channel(q);
                ncnn::Mat in1_padded_1 = in1_padded[1].channel(q);
                ncnn::Mat in1_padded_2 = in1_padded[2].channel(q);
                ncnn::Mat in1_padded_3 = in1_padded[3].channel(q);
                ncnn::Mat in1_padded_4 = in1_padded[4].channel(q);
                ncnn::Mat in1_padded_5 = in1_padded[5].channel(q);
                ncnn::Mat in1_padded_6 = in1_padded[6].channel(q);
                ncnn::Mat in1_padded_7 = in1_padded[7].channel(q);

                for (int i = 0; i < h_padded; i++)
                {
                    const float* outptr0 = in1_padded_0.row(i);
                    float* outptr1 = in1_padded_1.row(i) + w_padded - 1;
                    float* outptr2 = in1_padded_2.row(h_padded - 1 - i) + w_padded - 1;
                    float* outptr3 = in1_padded_3.row(h_padded - 1 - i);

                    for (int j = 0; j < w_padded; j++)
                    {
                        float* outptr4 = in1_padded_4.row(j) + i;
                        float* outptr5 = in1_padded_5.row(j) + h_padded - 1 - i;
                        float* outptr6 = in1_padded_6.row(w_padded - 1 - j) + h_padded - 1 - i;
                        float* outptr7 = in1_padded_7.row(w_padded - 1 - j) + i;

                        float v = *outptr0++;

                        *outptr1-- = v;
                        *outptr2-- = v;
                        *outptr3++ = v;
                        *outptr4 = v;
                        *outptr5 = v;
                        *outptr6 = v;
                        *outptr7 = v;
                    }
                }
            }
        }

        ncnn::Mat flow[8];
        for (int ti = 0; ti < 8; ti++)
        {
            // flownet
            {
                ncnn::Extractor ex = flownet.create_extractor();

                if (uhd_mode)
                {
                    ncnn::Mat in0_padded_downscaled;
                    ncnn::Mat in1_padded_downscaled;
                    rife_uhd_downscale_image->forward(in0_padded[ti], in0_padded_downscaled, opt);
                    rife_uhd_downscale_image->forward(in1_padded[ti], in1_padded_downscaled, opt);

                    ex.input("input0", in0_padded_downscaled);
                    ex.input("input1", in1_padded_downscaled);

                    ncnn::Mat flow_downscaled;
                    ex.extract("flow", flow_downscaled);

                    ncnn::Mat flow_half;
                    rife_uhd_upscale_flow->forward(flow_downscaled, flow_half, opt);

                    rife_uhd_double_flow->forward(flow_half, flow[ti], opt);
                }
                else
                {
                    ex.input("input0", in0_padded[ti]);
                    ex.input("input1", in1_padded[ti]);
                    ex.extract("flow", flow[ti]);
                }
            }
        }

        ncnn::Mat flow_reversed[8];
        if (tta_temporal_mode)
        {
            for (int ti = 0; ti < 8; ti++)
            {
                // flownet
                {
                    ncnn::Extractor ex = flownet.create_extractor();

                    if (uhd_mode)
                    {
                        ncnn::Mat in0_padded_downscaled;
                        ncnn::Mat in1_padded_downscaled;
                        rife_uhd_downscale_image->forward(in0_padded[ti], in0_padded_downscaled, opt);
                        rife_uhd_downscale_image->forward(in1_padded[ti], in1_padded_downscaled, opt);

                        ex.input("input0", in1_padded_downscaled);
                        ex.input("input1", in0_padded_downscaled);

                        ncnn::Mat flow_downscaled;
                        ex.extract("flow", flow_downscaled);

                        ncnn::Mat flow_half;
                        rife_uhd_upscale_flow->forward(flow_downscaled, flow_half, opt);

                        rife_uhd_double_flow->forward(flow_half, flow_reversed[ti], opt);
                    }
                    else
                    {
                        ex.input("input0", in1_padded[ti]);
                        ex.input("input1", in0_padded[ti]);
                        ex.extract("flow", flow_reversed[ti]);
                    }
                }

                // merge flow and flow_reversed
                {
                    float* flow_x = flow[ti].channel(0);
                    float* flow_y = flow[ti].channel(1);
                    float* flow_reversed_x = flow_reversed[ti].channel(0);
                    float* flow_reversed_y = flow_reversed[ti].channel(1);

                    if (rife_v2)
                    {
                        float* flow_z = flow[ti].channel(2);
                        float* flow_w = flow[ti].channel(3);
                        float* flow_reversed_z = flow_reversed[ti].channel(2);
                        float* flow_reversed_w = flow_reversed[ti].channel(3);

                        for (int i = 0; i < flow[ti].h; i++)
                        {
                            for (int j = 0; j < flow[ti].w; j++)
                            {
                                float x = (*flow_x + *flow_reversed_z) * 0.5f;
                                float y = (*flow_y + *flow_reversed_w) * 0.5f;
                                float z = (*flow_z + *flow_reversed_x) * 0.5f;
                                float w = (*flow_w + *flow_reversed_y) * 0.5f;

                                *flow_x++ = x;
                                *flow_y++ = y;
                                *flow_z++ = z;
                                *flow_w++ = w;
                                *flow_reversed_x++ = z;
                                *flow_reversed_y++ = w;
                                *flow_reversed_z++ = x;
                                *flow_reversed_w++ = y;
                            }
                        }
                    }
                    else
                    {
                        for (int i = 0; i < flow[ti].h; i++)
                        {
                            for (int j = 0; j < flow[ti].w; j++)
                            {
                                float x = (*flow_x - *flow_reversed_x) * 0.5f;
                                float y = (*flow_y - *flow_reversed_y) * 0.5f;

                                *flow_x++ = x;
                                *flow_y++ = y;
                                *flow_reversed_x++ = -x;
                                *flow_reversed_y++ = -y;
                            }
                        }
                    }
                }
            }
        }

        // avg flow
        ncnn::Mat flow0[8];
        ncnn::Mat flow1[8];
        {
            ncnn::Mat flow_x0 = flow[0].channel(0);
            ncnn::Mat flow_x1 = flow[1].channel(0);
            ncnn::Mat flow_x2 = flow[2].channel(0);
            ncnn::Mat flow_x3 = flow[3].channel(0);
            ncnn::Mat flow_x4 = flow[4].channel(0);
            ncnn::Mat flow_x5 = flow[5].channel(0);
            ncnn::Mat flow_x6 = flow[6].channel(0);
            ncnn::Mat flow_x7 = flow[7].channel(0);

            ncnn::Mat flow_y0 = flow[0].channel(1);
            ncnn::Mat flow_y1 = flow[1].channel(1);
            ncnn::Mat flow_y2 = flow[2].channel(1);
            ncnn::Mat flow_y3 = flow[3].channel(1);
            ncnn::Mat flow_y4 = flow[4].channel(1);
            ncnn::Mat flow_y5 = flow[5].channel(1);
            ncnn::Mat flow_y6 = flow[6].channel(1);
            ncnn::Mat flow_y7 = flow[7].channel(1);

            if (rife_v2)
            {
                ncnn::Mat flow_z0 = flow[0].channel(2);
                ncnn::Mat flow_z1 = flow[1].channel(2);
                ncnn::Mat flow_z2 = flow[2].channel(2);
                ncnn::Mat flow_z3 = flow[3].channel(2);
                ncnn::Mat flow_z4 = flow[4].channel(2);
                ncnn::Mat flow_z5 = flow[5].channel(2);
                ncnn::Mat flow_z6 = flow[6].channel(2);
                ncnn::Mat flow_z7 = flow[7].channel(2);

                ncnn::Mat flow_w0 = flow[0].channel(3);
                ncnn::Mat flow_w1 = flow[1].channel(3);
                ncnn::Mat flow_w2 = flow[2].channel(3);
                ncnn::Mat flow_w3 = flow[3].channel(3);
                ncnn::Mat flow_w4 = flow[4].channel(3);
                ncnn::Mat flow_w5 = flow[5].channel(3);
                ncnn::Mat flow_w6 = flow[6].channel(3);
                ncnn::Mat flow_w7 = flow[7].channel(3);

                for (int i = 0; i < flow_x0.h; i++)
                {
                    float* x0 = flow_x0.row(i);
                    float* x1 = flow_x1.row(i) + flow_x0.w - 1;
                    float* x2 = flow_x2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                    float* x3 = flow_x3.row(flow_x0.h - 1 - i);

                    float* y0 = flow_y0.row(i);
                    float* y1 = flow_y1.row(i) + flow_x0.w - 1;
                    float* y2 = flow_y2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                    float* y3 = flow_y3.row(flow_x0.h - 1 - i);

                    float* z0 = flow_z0.row(i);
                    float* z1 = flow_z1.row(i) + flow_x0.w - 1;
                    float* z2 = flow_z2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                    float* z3 = flow_z3.row(flow_x0.h - 1 - i);

                    float* w0 = flow_w0.row(i);
                    float* w1 = flow_w1.row(i) + flow_x0.w - 1;
                    float* w2 = flow_w2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                    float* w3 = flow_w3.row(flow_x0.h - 1 - i);

                    for (int j = 0; j < flow_x0.w; j++)
                    {
                        float* x4 = flow_x4.row(j) + i;
                        float* x5 = flow_x5.row(j) + flow_x0.h - 1 - i;
                        float* x6 = flow_x6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                        float* x7 = flow_x7.row(flow_x0.w - 1 - j) + i;

                        float* y4 = flow_y4.row(j) + i;
                        float* y5 = flow_y5.row(j) + flow_x0.h - 1 - i;
                        float* y6 = flow_y6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                        float* y7 = flow_y7.row(flow_x0.w - 1 - j) + i;

                        float* z4 = flow_z4.row(j) + i;
                        float* z5 = flow_z5.row(j) + flow_x0.h - 1 - i;
                        float* z6 = flow_z6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                        float* z7 = flow_z7.row(flow_x0.w - 1 - j) + i;

                        float* w4 = flow_w4.row(j) + i;
                        float* w5 = flow_w5.row(j) + flow_x0.h - 1 - i;
                        float* w6 = flow_w6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                        float* w7 = flow_w7.row(flow_x0.w - 1 - j) + i;

                        float x = (*x0 + -*x1 + -*x2 + *x3 + *y4 + *y5 + -*y6 + -*y7) * 0.125f;
                        float y = (*y0 + *y1 + -*y2 + -*y3 + *x4 + -*x5 + -*x6 + *x7) * 0.125f;
                        float z = (*z0 + -*z1 + -*z2 + *z3 + *w4 + *w5 + -*w6 + -*w7) * 0.125f;
                        float w = (*w0 + *w1 + -*w2 + -*w3 + *z4 + -*z5 + -*z6 + *z7) * 0.125f;

                        *x0++ = x;
                        *x1-- = -x;
                        *x2-- = -x;
                        *x3++ = x;
                        *x4 = y;
                        *x5 = -y;
                        *x6 = -y;
                        *x7 = y;

                        *y0++ = y;
                        *y1-- = y;
                        *y2-- = -y;
                        *y3++ = -y;
                        *y4 = x;
                        *y5 = x;
                        *y6 = -x;
                        *y7 = -x;

                        *z0++ = z;
                        *z1-- = -z;
                        *z2-- = -z;
                        *z3++ = z;
                        *z4 = w;
                        *z5 = -w;
                        *z6 = -w;
                        *z7 = w;

                        *w0++ = w;
                        *w1-- = w;
                        *w2-- = -w;
                        *w3++ = -w;
                        *w4 = z;
                        *w5 = z;
                        *w6 = -z;
                        *w7 = -z;
                    }
                }
            }
            else
            {
                for (int i = 0; i < flow_x0.h; i++)
                {
                    float* x0 = flow_x0.row(i);
                    float* x1 = flow_x1.row(i) + flow_x0.w - 1;
                    float* x2 = flow_x2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                    float* x3 = flow_x3.row(flow_x0.h - 1 - i);

                    float* y0 = flow_y0.row(i);
                    float* y1 = flow_y1.row(i) + flow_x0.w - 1;
                    float* y2 = flow_y2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                    float* y3 = flow_y3.row(flow_x0.h - 1 - i);

                    for (int j = 0; j < flow_x0.w; j++)
                    {
                        float* x4 = flow_x4.row(j) + i;
                        float* x5 = flow_x5.row(j) + flow_x0.h - 1 - i;
                        float* x6 = flow_x6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                        float* x7 = flow_x7.row(flow_x0.w - 1 - j) + i;

                        float* y4 = flow_y4.row(j) + i;
                        float* y5 = flow_y5.row(j) + flow_x0.h - 1 - i;
                        float* y6 = flow_y6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                        float* y7 = flow_y7.row(flow_x0.w - 1 - j) + i;

                        float x = (*x0 + -*x1 + -*x2 + *x3 + *y4 + *y5 + -*y6 + -*y7) * 0.125f;
                        float y = (*y0 + *y1 + -*y2 + -*y3 + *x4 + -*x5 + -*x6 + *x7) * 0.125f;

                        *x0++ = x;
                        *x1-- = -x;
                        *x2-- = -x;
                        *x3++ = x;
                        *x4 = y;
                        *x5 = -y;
                        *x6 = -y;
                        *x7 = y;

                        *y0++ = y;
                        *y1-- = y;
                        *y2-- = -y;
                        *y3++ = -y;
                        *y4 = x;
                        *y5 = x;
                        *y6 = -x;
                        *y7 = -x;
                    }
                }
            }
        }

        if (tta_temporal_mode)
        {
            ncnn::Mat flow_x0 = flow_reversed[0].channel(0);
            ncnn::Mat flow_x1 = flow_reversed[1].channel(0);
            ncnn::Mat flow_x2 = flow_reversed[2].channel(0);
            ncnn::Mat flow_x3 = flow_reversed[3].channel(0);
            ncnn::Mat flow_x4 = flow_reversed[4].channel(0);
            ncnn::Mat flow_x5 = flow_reversed[5].channel(0);
            ncnn::Mat flow_x6 = flow_reversed[6].channel(0);
            ncnn::Mat flow_x7 = flow_reversed[7].channel(0);

            ncnn::Mat flow_y0 = flow_reversed[0].channel(1);
            ncnn::Mat flow_y1 = flow_reversed[1].channel(1);
            ncnn::Mat flow_y2 = flow_reversed[2].channel(1);
            ncnn::Mat flow_y3 = flow_reversed[3].channel(1);
            ncnn::Mat flow_y4 = flow_reversed[4].channel(1);
            ncnn::Mat flow_y5 = flow_reversed[5].channel(1);
            ncnn::Mat flow_y6 = flow_reversed[6].channel(1);
            ncnn::Mat flow_y7 = flow_reversed[7].channel(1);

            if (rife_v2)
            {
                ncnn::Mat flow_z0 = flow_reversed[0].channel(2);
                ncnn::Mat flow_z1 = flow_reversed[1].channel(2);
                ncnn::Mat flow_z2 = flow_reversed[2].channel(2);
                ncnn::Mat flow_z3 = flow_reversed[3].channel(2);
                ncnn::Mat flow_z4 = flow_reversed[4].channel(2);
                ncnn::Mat flow_z5 = flow_reversed[5].channel(2);
                ncnn::Mat flow_z6 = flow_reversed[6].channel(2);
                ncnn::Mat flow_z7 = flow_reversed[7].channel(2);

                ncnn::Mat flow_w0 = flow_reversed[0].channel(3);
                ncnn::Mat flow_w1 = flow_reversed[1].channel(3);
                ncnn::Mat flow_w2 = flow_reversed[2].channel(3);
                ncnn::Mat flow_w3 = flow_reversed[3].channel(3);
                ncnn::Mat flow_w4 = flow_reversed[4].channel(3);
                ncnn::Mat flow_w5 = flow_reversed[5].channel(3);
                ncnn::Mat flow_w6 = flow_reversed[6].channel(3);
                ncnn::Mat flow_w7 = flow_reversed[7].channel(3);

                for (int i = 0; i < flow_x0.h; i++)
                {
                    float* x0 = flow_x0.row(i);
                    float* x1 = flow_x1.row(i) + flow_x0.w - 1;
                    float* x2 = flow_x2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                    float* x3 = flow_x3.row(flow_x0.h - 1 - i);

                    float* y0 = flow_y0.row(i);
                    float* y1 = flow_y1.row(i) + flow_x0.w - 1;
                    float* y2 = flow_y2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                    float* y3 = flow_y3.row(flow_x0.h - 1 - i);

                    float* z0 = flow_z0.row(i);
                    float* z1 = flow_z1.row(i) + flow_x0.w - 1;
                    float* z2 = flow_z2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                    float* z3 = flow_z3.row(flow_x0.h - 1 - i);

                    float* w0 = flow_w0.row(i);
                    float* w1 = flow_w1.row(i) + flow_x0.w - 1;
                    float* w2 = flow_w2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                    float* w3 = flow_w3.row(flow_x0.h - 1 - i);

                    for (int j = 0; j < flow_x0.w; j++)
                    {
                        float* x4 = flow_x4.row(j) + i;
                        float* x5 = flow_x5.row(j) + flow_x0.h - 1 - i;
                        float* x6 = flow_x6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                        float* x7 = flow_x7.row(flow_x0.w - 1 - j) + i;

                        float* y4 = flow_y4.row(j) + i;
                        float* y5 = flow_y5.row(j) + flow_x0.h - 1 - i;
                        float* y6 = flow_y6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                        float* y7 = flow_y7.row(flow_x0.w - 1 - j) + i;

                        float* z4 = flow_z4.row(j) + i;
                        float* z5 = flow_z5.row(j) + flow_x0.h - 1 - i;
                        float* z6 = flow_z6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                        float* z7 = flow_z7.row(flow_x0.w - 1 - j) + i;

                        float* w4 = flow_w4.row(j) + i;
                        float* w5 = flow_w5.row(j) + flow_x0.h - 1 - i;
                        float* w6 = flow_w6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                        float* w7 = flow_w7.row(flow_x0.w - 1 - j) + i;

                        float x = (*x0 + -*x1 + -*x2 + *x3 + *y4 + *y5 + -*y6 + -*y7) * 0.125f;
                        float y = (*y0 + *y1 + -*y2 + -*y3 + *x4 + -*x5 + -*x6 + *x7) * 0.125f;
                        float z = (*z0 + -*z1 + -*z2 + *z3 + *w4 + *w5 + -*w6 + -*w7) * 0.125f;
                        float w = (*w0 + *w1 + -*w2 + -*w3 + *z4 + -*z5 + -*z6 + *z7) * 0.125f;

                        *x0++ = x;
                        *x1-- = -x;
                        *x2-- = -x;
                        *x3++ = x;
                        *x4 = y;
                        *x5 = -y;
                        *x6 = -y;
                        *x7 = y;

                        *y0++ = y;
                        *y1-- = y;
                        *y2-- = -y;
                        *y3++ = -y;
                        *y4 = x;
                        *y5 = x;
                        *y6 = -x;
                        *y7 = -x;

                        *z0++ = z;
                        *z1-- = -z;
                        *z2-- = -z;
                        *z3++ = z;
                        *z4 = w;
                        *z5 = -w;
                        *z6 = -w;
                        *z7 = w;

                        *w0++ = w;
                        *w1-- = w;
                        *w2-- = -w;
                        *w3++ = -w;
                        *w4 = z;
                        *w5 = z;
                        *w6 = -z;
                        *w7 = -z;
                    }
                }
            }
            else
            {
                for (int i = 0; i < flow_x0.h; i++)
                {
                    float* x0 = flow_x0.row(i);
                    float* x1 = flow_x1.row(i) + flow_x0.w - 1;
                    float* x2 = flow_x2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                    float* x3 = flow_x3.row(flow_x0.h - 1 - i);

                    float* y0 = flow_y0.row(i);
                    float* y1 = flow_y1.row(i) + flow_x0.w - 1;
                    float* y2 = flow_y2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                    float* y3 = flow_y3.row(flow_x0.h - 1 - i);

                    for (int j = 0; j < flow_x0.w; j++)
                    {
                        float* x4 = flow_x4.row(j) + i;
                        float* x5 = flow_x5.row(j) + flow_x0.h - 1 - i;
                        float* x6 = flow_x6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                        float* x7 = flow_x7.row(flow_x0.w - 1 - j) + i;

                        float* y4 = flow_y4.row(j) + i;
                        float* y5 = flow_y5.row(j) + flow_x0.h - 1 - i;
                        float* y6 = flow_y6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                        float* y7 = flow_y7.row(flow_x0.w - 1 - j) + i;

                        float x = (*x0 + -*x1 + -*x2 + *x3 + *y4 + *y5 + -*y6 + -*y7) * 0.125f;
                        float y = (*y0 + *y1 + -*y2 + -*y3 + *x4 + -*x5 + -*x6 + *x7) * 0.125f;

                        *x0++ = x;
                        *x1-- = -x;
                        *x2-- = -x;
                        *x3++ = x;
                        *x4 = y;
                        *x5 = -y;
                        *x6 = -y;
                        *x7 = y;

                        *y0++ = y;
                        *y1-- = y;
                        *y2-- = -y;
                        *y3++ = -y;
                        *y4 = x;
                        *y5 = x;
                        *y6 = -x;
                        *y7 = -x;
                    }
                }
            }

            // merge flow and flow_reversed
            for (int ti = 0; ti < 8; ti++)
            {
                float* flow_x = flow[ti].channel(0);
                float* flow_y = flow[ti].channel(1);
                float* flow_reversed_x = flow_reversed[ti].channel(0);
                float* flow_reversed_y = flow_reversed[ti].channel(1);

                if (rife_v2)
                {
                    float* flow_z = flow[ti].channel(2);
                    float* flow_w = flow[ti].channel(3);
                    float* flow_reversed_z = flow_reversed[ti].channel(2);
                    float* flow_reversed_w = flow_reversed[ti].channel(3);

                    for (int i = 0; i < flow[ti].h; i++)
                    {
                        for (int j = 0; j < flow[ti].w; j++)
                        {
                            float x = (*flow_x + *flow_reversed_z) * 0.5f;
                            float y = (*flow_y + *flow_reversed_w) * 0.5f;
                            float z = (*flow_z + *flow_reversed_x) * 0.5f;
                            float w = (*flow_w + *flow_reversed_y) * 0.5f;

                            *flow_x++ = x;
                            *flow_y++ = y;
                            *flow_z++ = z;
                            *flow_w++ = w;
                            *flow_reversed_x++ = z;
                            *flow_reversed_y++ = w;
                            *flow_reversed_z++ = x;
                            *flow_reversed_w++ = y;
                        }
                    }
                }
                else
                {
                    for (int i = 0; i < flow[ti].h; i++)
                    {
                        for (int j = 0; j < flow[ti].w; j++)
                        {
                            float x = (*flow_x - *flow_reversed_x) * 0.5f;
                            float y = (*flow_y - *flow_reversed_y) * 0.5f;

                            *flow_x++ = x;
                            *flow_y++ = y;
                            *flow_reversed_x++ = -x;
                            *flow_reversed_y++ = -y;
                        }
                    }
                }
            }
        }

        if (rife_v2)
        {
            for (int ti = 0; ti < 8; ti++)
            {
                std::vector<ncnn::Mat> inputs(1);
                inputs[0] = flow[ti];
                std::vector<ncnn::Mat> outputs(2);
                rife_v2_slice_flow->forward(inputs, outputs, opt);
                flow0[ti] = outputs[0];
                flow1[ti] = outputs[1];
            }
        }

        ncnn::Mat out_padded[8];
        ncnn::Mat out_padded_reversed[8];
        for (int ti = 0; ti < 8; ti++)
        {
            // contextnet
            ncnn::Mat ctx0[4];
            ncnn::Mat ctx1[4];
            {
                ncnn::Extractor ex = contextnet.create_extractor();

                ex.input("input.1", in0_padded[ti]);
                if (rife_v2)
                {
                    ex.input("flow.0", flow0[ti]);
                }
                else
                {
                    ex.input("flow.0", flow[ti]);
                }
                ex.extract("f1", ctx0[0]);
                ex.extract("f2", ctx0[1]);
                ex.extract("f3", ctx0[2]);
                ex.extract("f4", ctx0[3]);
            }
            {
                ncnn::Extractor ex = contextnet.create_extractor();

                ex.input("input.1", in1_padded[ti]);
                if (rife_v2)
                {
                    ex.input("flow.0", flow1[ti]);
                }
                else
                {
                    ex.input("flow.1", flow[ti]);
                }
                ex.extract("f1", ctx1[0]);
                ex.extract("f2", ctx1[1]);
                ex.extract("f3", ctx1[2]);
                ex.extract("f4", ctx1[3]);
            }

            // fusionnet
            {
                ncnn::Extractor ex = fusionnet.create_extractor();

                ex.input("img0", in0_padded[ti]);
                ex.input("img1", in1_padded[ti]);
                ex.input("flow", flow[ti]);
                ex.input("3", ctx0[0]);
                ex.input("4", ctx0[1]);
                ex.input("5", ctx0[2]);
                ex.input("6", ctx0[3]);
                ex.input("7", ctx1[0]);
                ex.input("8", ctx1[1]);
                ex.input("9", ctx1[2]);
                ex.input("10", ctx1[3]);

                ex.extract("output", out_padded[ti]);
            }

            if (tta_temporal_mode)
            {
                // fusionnet
                {
                    ncnn::Extractor ex = fusionnet.create_extractor();

                    ex.input("img0", in1_padded[ti]);
                    ex.input("img1", in0_padded[ti]);
                    ex.input("flow", flow_reversed[ti]);
                    ex.input("3", ctx1[0]);
                    ex.input("4", ctx1[1]);
                    ex.input("5", ctx1[2]);
                    ex.input("6", ctx1[3]);
                    ex.input("7", ctx0[0]);
                    ex.input("8", ctx0[1]);
                    ex.input("9", ctx0[2]);
                    ex.input("10", ctx0[3]);

                    ex.extract("output", out_padded_reversed[ti]);
                }
            }
        }

        // cut padding and postproc
        out.create(w, h, 3);
        if (tta_temporal_mode)
        {
            for (int q = 0; q < 3; q++)
            {
                const ncnn::Mat out_padded_0 = out_padded[0].channel(q);
                const ncnn::Mat out_padded_1 = out_padded[1].channel(q);
                const ncnn::Mat out_padded_2 = out_padded[2].channel(q);
                const ncnn::Mat out_padded_3 = out_padded[3].channel(q);
                const ncnn::Mat out_padded_4 = out_padded[4].channel(q);
                const ncnn::Mat out_padded_5 = out_padded[5].channel(q);
                const ncnn::Mat out_padded_6 = out_padded[6].channel(q);
                const ncnn::Mat out_padded_7 = out_padded[7].channel(q);
                const ncnn::Mat out_padded_reversed_0 = out_padded_reversed[0].channel(q);
                const ncnn::Mat out_padded_reversed_1 = out_padded_reversed[1].channel(q);
                const ncnn::Mat out_padded_reversed_2 = out_padded_reversed[2].channel(q);
                const ncnn::Mat out_padded_reversed_3 = out_padded_reversed[3].channel(q);
                const ncnn::Mat out_padded_reversed_4 = out_padded_reversed[4].channel(q);
                const ncnn::Mat out_padded_reversed_5 = out_padded_reversed[5].channel(q);
                const ncnn::Mat out_padded_reversed_6 = out_padded_reversed[6].channel(q);
                const ncnn::Mat out_padded_reversed_7 = out_padded_reversed[7].channel(q);
                float* outptr = out.channel(q);

                for (int i = 0; i < h; i++)
                {
                    const float* ptr0 = out_padded_0.row(i);
                    const float* ptr1 = out_padded_1.row(i) + w_padded - 1;
                    const float* ptr2 = out_padded_2.row(h_padded - 1 - i) + w_padded - 1;
                    const float* ptr3 = out_padded_3.row(h_padded - 1 - i);
                    const float* ptrr0 = out_padded_reversed_0.row(i);
                    const float* ptrr1 = out_padded_reversed_1.row(i) + w_padded - 1;
                    const float* ptrr2 = out_padded_reversed_2.row(h_padded - 1 - i) + w_padded - 1;
                    const float* ptrr3 = out_padded_reversed_3.row(h_padded - 1 - i);

                    for (int j = 0; j < w; j++)
                    {
                        const float* ptr4 = out_padded_4.row(j) + i;
                        const float* ptr5 = out_padded_5.row(j) + h_padded - 1 - i;
                        const float* ptr6 = out_padded_6.row(w_padded - 1 - j) + h_padded - 1 - i;
                        const float* ptr7 = out_padded_7.row(w_padded - 1 - j) + i;
                        const float* ptrr4 = out_padded_reversed_4.row(j) + i;
                        const float* ptrr5 = out_padded_reversed_5.row(j) + h_padded - 1 - i;
                        const float* ptrr6 = out_padded_reversed_6.row(w_padded - 1 - j) + h_padded - 1 - i;
                        const float* ptrr7 = out_padded_reversed_7.row(w_padded - 1 - j) + i;

                        float v = (*ptr0++ + *ptr1-- + *ptr2-- + *ptr3++ + *ptr4 + *ptr5 + *ptr6 + *ptr7) / 8;
                        float vr = (*ptrr0++ + *ptrr1-- + *ptrr2-- + *ptrr3++ + *ptrr4 + *ptrr5 + *ptrr6 + *ptrr7) / 8;

                        *outptr++ = (v + vr) * 0.5f * 255.f + 0.5f;
                    }
                }
            }
        }
        else
        {
            for (int q = 0; q < 3; q++)
            {
                const ncnn::Mat out_padded_0 = out_padded[0].channel(q);
                const ncnn::Mat out_padded_1 = out_padded[1].channel(q);
                const ncnn::Mat out_padded_2 = out_padded[2].channel(q);
                const ncnn::Mat out_padded_3 = out_padded[3].channel(q);
                const ncnn::Mat out_padded_4 = out_padded[4].channel(q);
                const ncnn::Mat out_padded_5 = out_padded[5].channel(q);
                const ncnn::Mat out_padded_6 = out_padded[6].channel(q);
                const ncnn::Mat out_padded_7 = out_padded[7].channel(q);
                float* outptr = out.channel(q);

                for (int i = 0; i < h; i++)
                {
                    const float* ptr0 = out_padded_0.row(i);
                    const float* ptr1 = out_padded_1.row(i) + w_padded - 1;
                    const float* ptr2 = out_padded_2.row(h_padded - 1 - i) + w_padded - 1;
                    const float* ptr3 = out_padded_3.row(h_padded - 1 - i);

                    for (int j = 0; j < w; j++)
                    {
                        const float* ptr4 = out_padded_4.row(j) + i;
                        const float* ptr5 = out_padded_5.row(j) + h_padded - 1 - i;
                        const float* ptr6 = out_padded_6.row(w_padded - 1 - j) + h_padded - 1 - i;
                        const float* ptr7 = out_padded_7.row(w_padded - 1 - j) + i;

                        float v = (*ptr0++ + *ptr1-- + *ptr2-- + *ptr3++ + *ptr4 + *ptr5 + *ptr6 + *ptr7) / 8;

                        *outptr++ = v * 255.f + 0.5f;
                    }
                }
            }
        }
    }
    else
    {
        // preproc and border padding
        ncnn::Mat in0_padded;
        ncnn::Mat in1_padded;
        {
            in0_padded.create(w_padded, h_padded, 3);
            for (int q = 0; q < 3; q++)
            {
                float* outptr = in0_padded.channel(q);

                int i = 0;
                for (; i < h; i++)
                {
                    const float* ptr = in0.channel(q).row(i);

                    int j = 0;
                    for (; j < w; j++)
                    {
                        *outptr++ = *ptr++ * (1 / 255.f);
                    }
                    for (; j < w_padded; j++)
                    {
                        *outptr++ = 0.f;
                    }
                }
                for (; i < h_padded; i++)
                {
                    for (int j = 0; j < w_padded; j++)
                    {
                        *outptr++ = 0.f;
                    }
                }
            }
        }
        {
            in1_padded.create(w_padded, h_padded, 3);
            for (int q = 0; q < 3; q++)
            {
                float* outptr = in1_padded.channel(q);

                int i = 0;
                for (; i < h; i++)
                {
                    const float* ptr = in1.channel(q).row(i);

                    int j = 0;
                    for (; j < w; j++)
                    {
                        *outptr++ = *ptr++ * (1 / 255.f);
                    }
                    for (; j < w_padded; j++)
                    {
                        *outptr++ = 0.f;
                    }
                }
                for (; i < h_padded; i++)
                {
                    for (int j = 0; j < w_padded; j++)
                    {
                        *outptr++ = 0.f;
                    }
                }
            }
        }

        // flownet
        ncnn::Mat flow;
        ncnn::Mat flow0;
        ncnn::Mat flow1;
        {
            ncnn::Extractor ex = flownet.create_extractor();

            if (uhd_mode)
            {
                ncnn::Mat in0_padded_downscaled;
                ncnn::Mat in1_padded_downscaled;
                rife_uhd_downscale_image->forward(in0_padded, in0_padded_downscaled, opt);
                rife_uhd_downscale_image->forward(in1_padded, in1_padded_downscaled, opt);

                ex.input("input0", in0_padded_downscaled);
                ex.input("input1", in1_padded_downscaled);

                ncnn::Mat flow_downscaled;
                ex.extract("flow", flow_downscaled);

                ncnn::Mat flow_half;
                rife_uhd_upscale_flow->forward(flow_downscaled, flow_half, opt);

                rife_uhd_double_flow->forward(flow_half, flow, opt);
            }
            else
            {
                ex.input("input0", in0_padded);
                ex.input("input1", in1_padded);
                ex.extract("flow", flow);
            }
        }

        ncnn::Mat flow_reversed;
        if (tta_temporal_mode)
        {
            // flownet
            ncnn::Extractor ex = flownet.create_extractor();

            if (uhd_mode)
            {
                ncnn::Mat in0_padded_downscaled;
                ncnn::Mat in1_padded_downscaled;
                rife_uhd_downscale_image->forward(in0_padded, in0_padded_downscaled, opt);
                rife_uhd_downscale_image->forward(in1_padded, in1_padded_downscaled, opt);

                ex.input("input0", in1_padded_downscaled);
                ex.input("input1", in0_padded_downscaled);

                ncnn::Mat flow_downscaled;
                ex.extract("flow", flow_downscaled);

                ncnn::Mat flow_half;
                rife_uhd_upscale_flow->forward(flow_downscaled, flow_half, opt);

                rife_uhd_double_flow->forward(flow_half, flow_reversed, opt);
            }
            else
            {
                ex.input("input0", in1_padded);
                ex.input("input1", in0_padded);
                ex.extract("flow", flow_reversed);
            }

            // merge flow and flow_reversed
            {
                float* flow_x = flow.channel(0);
                float* flow_y = flow.channel(1);
                float* flow_reversed_x = flow_reversed.channel(0);
                float* flow_reversed_y = flow_reversed.channel(1);

                if (rife_v2)
                {
                    float* flow_z = flow.channel(2);
                    float* flow_w = flow.channel(3);
                    float* flow_reversed_z = flow_reversed.channel(2);
                    float* flow_reversed_w = flow_reversed.channel(3);

                    for (int i = 0; i < flow.h; i++)
                    {
                        for (int j = 0; j < flow.w; j++)
                        {
                            float x = (*flow_x + *flow_reversed_z) * 0.5f;
                            float y = (*flow_y + *flow_reversed_w) * 0.5f;
                            float z = (*flow_z + *flow_reversed_x) * 0.5f;
                            float w = (*flow_w + *flow_reversed_y) * 0.5f;

                            *flow_x++ = x;
                            *flow_y++ = y;
                            *flow_z++ = z;
                            *flow_w++ = w;
                            *flow_reversed_x++ = z;
                            *flow_reversed_y++ = w;
                            *flow_reversed_z++ = x;
                            *flow_reversed_w++ = y;
                        }
                    }
                }
                else
                {
                    for (int i = 0; i < flow.h; i++)
                    {
                        for (int j = 0; j < flow.w; j++)
                        {
                            float x = (*flow_x - *flow_reversed_x) * 0.5f;
                            float y = (*flow_y - *flow_reversed_y) * 0.5f;

                            *flow_x++ = x;
                            *flow_y++ = y;
                            *flow_reversed_x++ = -x;
                            *flow_reversed_y++ = -y;
                        }
                    }
                }
            }
        }

        if (rife_v2)
        {
            std::vector<ncnn::Mat> inputs(1);
            inputs[0] = flow;
            std::vector<ncnn::Mat> outputs(2);
            rife_v2_slice_flow->forward(inputs, outputs, opt);
            flow0 = outputs[0];
            flow1 = outputs[1];
        }

        // contextnet
        ncnn::Mat ctx0[4];
        ncnn::Mat ctx1[4];
        {
            ncnn::Extractor ex = contextnet.create_extractor();

            ex.input("input.1", in0_padded);
            if (rife_v2)
            {
                ex.input("flow.0", flow0);
            }
            else
            {
                ex.input("flow.0", flow);
            }
            ex.extract("f1", ctx0[0]);
            ex.extract("f2", ctx0[1]);
            ex.extract("f3", ctx0[2]);
            ex.extract("f4", ctx0[3]);
        }
        {
            ncnn::Extractor ex = contextnet.create_extractor();

            ex.input("input.1", in1_padded);
            if (rife_v2)
            {
                ex.input("flow.0", flow1);
            }
            else
            {
                ex.input("flow.1", flow);
            }
            ex.extract("f1", ctx1[0]);
            ex.extract("f2", ctx1[1]);
            ex.extract("f3", ctx1[2]);
            ex.extract("f4", ctx1[3]);
        }

        // fusionnet
        ncnn::Mat out_padded;
        {
            ncnn::Extractor ex = fusionnet.create_extractor();

            ex.input("img0", in0_padded);
            ex.input("img1", in1_padded);
            ex.input("flow", flow);
            ex.input("3", ctx0[0]);
            ex.input("4", ctx0[1]);
            ex.input("5", ctx0[2]);
            ex.input("6", ctx0[3]);
            ex.input("7", ctx1[0]);
            ex.input("8", ctx1[1]);
            ex.input("9", ctx1[2]);
            ex.input("10", ctx1[3]);

            ex.extract("output", out_padded);
        }

        ncnn::Mat out_padded_reversed;
        if (tta_temporal_mode)
        {
            // fusionnet
            {
                ncnn::Extractor ex = fusionnet.create_extractor();

                ex.input("img0", in1_padded);
                ex.input("img1", in0_padded);
                ex.input("flow", flow_reversed);
                ex.input("3", ctx1[0]);
                ex.input("4", ctx1[1]);
                ex.input("5", ctx1[2]);
                ex.input("6", ctx1[3]);
                ex.input("7", ctx0[0]);
                ex.input("8", ctx0[1]);
                ex.input("9", ctx0[2]);
                ex.input("10", ctx0[3]);

                ex.extract("output", out_padded_reversed);
            }
        }

        // cut padding and postproc
        out.create(w, h, 3);
        if (tta_temporal_mode)
        {
            for (int q = 0; q < 3; q++)
            {
                float* outptr = out.channel(q);
                const float* ptr = out_padded.channel(q);
                const float* ptr1 = out_padded_reversed.channel(q);

                for (int i = 0; i < h; i++)
                {
                    for (int j = 0; j < w; j++)
                    {
                        *outptr++ = (*ptr++ + *ptr1++) * 0.5f * 255.f + 0.5f;
                    }
                }
            }
        }
        else
        {
            for (int q = 0; q < 3; q++)
            {
                float* outptr = out.channel(q);
                const float* ptr = out_padded.channel(q);

                for (int i = 0; i < h; i++)
                {
                    for (int j = 0; j < w; j++)
                    {
                        *outptr++ = *ptr++ * 255.f + 0.5f;
                    }
                }
            }
        }
    }

    // download
    {
#if _WIN32
        out.to_pixels((unsigned char*)outimage.data, ncnn::Mat::PIXEL_RGB2BGR);
#else
        out.to_pixels((unsigned char*)outimage.data, ncnn::Mat::PIXEL_RGB);
#endif
    }

    return 0;
}

int RIFE::process_v4(const ncnn::Mat& in0image, const ncnn::Mat& in1image, float timestep, ncnn::Mat& outimage) const
{
    if (!vkdev)
    {
        // cpu only
        return process_cpu(in0image, in1image, timestep, outimage);
    }

    if (timestep == 0.f)
    {
        outimage = in0image;
        return 0;
    }

    if (timestep == 1.f)
    {
        outimage = in1image;
        return 0;
    }

    const unsigned char* pixel0data = (const unsigned char*)in0image.data;
    const unsigned char* pixel1data = (const unsigned char*)in1image.data;
    const int w = in0image.w;
    const int h = in0image.h;
    const int channels = 3;//in0image.elempack;

//     fprintf(stderr, "%d x %d\n", w, h);

    ncnn::VkAllocator* blob_vkallocator = vkdev->acquire_blob_allocator();
    ncnn::VkAllocator* staging_vkallocator = vkdev->acquire_staging_allocator();

    ncnn::Option opt = flownet.opt;
    opt.blob_vkallocator = blob_vkallocator;
    opt.workspace_vkallocator = blob_vkallocator;
    opt.staging_vkallocator = staging_vkallocator;

    // pad to 32n
    int w_padded = (w + 31) / 32 * 32;
    int h_padded = (h + 31) / 32 * 32;

    const size_t in_out_tile_elemsize = opt.use_fp16_storage ? 2u : 4u;

    ncnn::Mat in0;
    ncnn::Mat in1;
    if (opt.use_fp16_storage && opt.use_int8_storage)
    {
        in0 = ncnn::Mat(w, h, (unsigned char*)pixel0data, (size_t)channels, 1);
        in1 = ncnn::Mat(w, h, (unsigned char*)pixel1data, (size_t)channels, 1);
    }
    else
    {
#if _WIN32
        in0 = ncnn::Mat::from_pixels(pixel0data, ncnn::Mat::PIXEL_BGR2RGB, w, h);
        in1 = ncnn::Mat::from_pixels(pixel1data, ncnn::Mat::PIXEL_BGR2RGB, w, h);
#else
        in0 = ncnn::Mat::from_pixels(pixel0data, ncnn::Mat::PIXEL_RGB, w, h);
        in1 = ncnn::Mat::from_pixels(pixel1data, ncnn::Mat::PIXEL_RGB, w, h);
#endif
    }

    ncnn::VkCompute cmd(vkdev);

    // upload
    ncnn::VkMat in0_gpu;
    ncnn::VkMat in1_gpu;
    {
        cmd.record_clone(in0, in0_gpu, opt);
        cmd.record_clone(in1, in1_gpu, opt);
    }

    ncnn::VkMat out_gpu;

    if (tta_mode)
    {
        // preproc
        ncnn::VkMat in0_gpu_padded[8];
        ncnn::VkMat in1_gpu_padded[8];
        ncnn::VkMat timestep_gpu_padded[2];
        {
            in0_gpu_padded[0].create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in0_gpu_padded[1].create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in0_gpu_padded[2].create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in0_gpu_padded[3].create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in0_gpu_padded[4].create(h_padded, w_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in0_gpu_padded[5].create(h_padded, w_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in0_gpu_padded[6].create(h_padded, w_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in0_gpu_padded[7].create(h_padded, w_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);

            std::vector<ncnn::VkMat> bindings(9);
            bindings[0] = in0_gpu;
            bindings[1] = in0_gpu_padded[0];
            bindings[2] = in0_gpu_padded[1];
            bindings[3] = in0_gpu_padded[2];
            bindings[4] = in0_gpu_padded[3];
            bindings[5] = in0_gpu_padded[4];
            bindings[6] = in0_gpu_padded[5];
            bindings[7] = in0_gpu_padded[6];
            bindings[8] = in0_gpu_padded[7];

            std::vector<ncnn::vk_constant_type> constants(6);
            constants[0].i = in0_gpu.w;
            constants[1].i = in0_gpu.h;
            constants[2].i = in0_gpu.cstep;
            constants[3].i = in0_gpu_padded[0].w;
            constants[4].i = in0_gpu_padded[0].h;
            constants[5].i = in0_gpu_padded[0].cstep;

            cmd.record_pipeline(rife_preproc, bindings, constants, in0_gpu_padded[0]);
        }
        {
            in1_gpu_padded[0].create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in1_gpu_padded[1].create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in1_gpu_padded[2].create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in1_gpu_padded[3].create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in1_gpu_padded[4].create(h_padded, w_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in1_gpu_padded[5].create(h_padded, w_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in1_gpu_padded[6].create(h_padded, w_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);
            in1_gpu_padded[7].create(h_padded, w_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);

            std::vector<ncnn::VkMat> bindings(9);
            bindings[0] = in1_gpu;
            bindings[1] = in1_gpu_padded[0];
            bindings[2] = in1_gpu_padded[1];
            bindings[3] = in1_gpu_padded[2];
            bindings[4] = in1_gpu_padded[3];
            bindings[5] = in1_gpu_padded[4];
            bindings[6] = in1_gpu_padded[5];
            bindings[7] = in1_gpu_padded[6];
            bindings[8] = in1_gpu_padded[7];

            std::vector<ncnn::vk_constant_type> constants(6);
            constants[0].i = in1_gpu.w;
            constants[1].i = in1_gpu.h;
            constants[2].i = in1_gpu.cstep;
            constants[3].i = in1_gpu_padded[0].w;
            constants[4].i = in1_gpu_padded[0].h;
            constants[5].i = in1_gpu_padded[0].cstep;

            cmd.record_pipeline(rife_preproc, bindings, constants, in1_gpu_padded[0]);
        }
        {
            timestep_gpu_padded[0].create(w_padded, h_padded, 1, in_out_tile_elemsize, 1, blob_vkallocator);
            timestep_gpu_padded[1].create(h_padded, w_padded, 1, in_out_tile_elemsize, 1, blob_vkallocator);

            std::vector<ncnn::VkMat> bindings(2);
            bindings[0] = timestep_gpu_padded[0];
            bindings[1] = timestep_gpu_padded[1];

            std::vector<ncnn::vk_constant_type> constants(4);
            constants[0].i = timestep_gpu_padded[0].w;
            constants[1].i = timestep_gpu_padded[0].h;
            constants[2].i = timestep_gpu_padded[0].cstep;
            constants[3].f = timestep;

            cmd.record_pipeline(rife_v4_timestep, bindings, constants, timestep_gpu_padded[0]);
        }

        ncnn::VkMat out_gpu_padded[8];
        if (tta_temporal_mode)
        {
            ncnn::VkMat timestep_gpu_padded_reversed[2];
            {
                timestep_gpu_padded_reversed[0].create(w_padded, h_padded, 1, in_out_tile_elemsize, 1, blob_vkallocator);
                timestep_gpu_padded_reversed[1].create(h_padded, w_padded, 1, in_out_tile_elemsize, 1, blob_vkallocator);

                std::vector<ncnn::VkMat> bindings(2);
                bindings[0] = timestep_gpu_padded_reversed[0];
                bindings[1] = timestep_gpu_padded_reversed[1];

                std::vector<ncnn::vk_constant_type> constants(4);
                constants[0].i = timestep_gpu_padded_reversed[0].w;
                constants[1].i = timestep_gpu_padded_reversed[0].h;
                constants[2].i = timestep_gpu_padded_reversed[0].cstep;
                constants[3].f = 1.f - timestep;

                cmd.record_pipeline(rife_v4_timestep, bindings, constants, timestep_gpu_padded_reversed[0]);
            }

            ncnn::VkMat flow[4][8];
            ncnn::VkMat flow_reversed[4][8];
            for (int fi = 0; fi < 4; fi++)
            {
                for (int ti = 0; ti < 8; ti++)
                {
                    {
                        // flownet flow mask
                        ncnn::Extractor ex = flownet.create_extractor();
                        ex.set_blob_vkallocator(blob_vkallocator);
                        ex.set_workspace_vkallocator(blob_vkallocator);
                        ex.set_staging_vkallocator(staging_vkallocator);

                        ex.input("in0", in0_gpu_padded[ti]);
                        ex.input("in1", in1_gpu_padded[ti]);
                        ex.input("in2", timestep_gpu_padded[ti / 4]);

                        // intentional fall through
                        switch (fi)
                        {
                        case 3: ex.input("flow2", flow[2][ti]);
                        case 2: ex.input("flow1", flow[1][ti]);
                        case 1: ex.input("flow0", flow[0][ti]);
                        default:
                        {
                            char tmp[16];
                            sprintf(tmp, "flow%d", fi);
                            ex.extract(tmp, flow[fi][ti], cmd);
                        }
                        }
                    }

                    {
                        // flownet flow mask reversed
                        ncnn::Extractor ex = flownet.create_extractor();
                        ex.set_blob_vkallocator(blob_vkallocator);
                        ex.set_workspace_vkallocator(blob_vkallocator);
                        ex.set_staging_vkallocator(staging_vkallocator);

                        ex.input("in0", in1_gpu_padded[ti]);
                        ex.input("in1", in0_gpu_padded[ti]);
                        ex.input("in2", timestep_gpu_padded_reversed[ti / 4]);

                        // intentional fall through
                        switch (fi)
                        {
                        case 3: ex.input("flow2", flow_reversed[2][ti]);
                        case 2: ex.input("flow1", flow_reversed[1][ti]);
                        case 1: ex.input("flow0", flow_reversed[0][ti]);
                        default:
                        {
                            char tmp[16];
                            sprintf(tmp, "flow%d", fi);
                            ex.extract(tmp, flow_reversed[fi][ti], cmd);
                        }
                        }
                    }

                    // merge flow and flow_reversed
                    {
                        std::vector<ncnn::VkMat> bindings(2);
                        bindings[0] = flow[fi][ti];
                        bindings[1] = flow_reversed[fi][ti];

                        std::vector<ncnn::vk_constant_type> constants(3);
                        constants[0].i = flow[fi][ti].w;
                        constants[1].i = flow[fi][ti].h;
                        constants[2].i = flow[fi][ti].cstep;

                        ncnn::VkMat dispatcher;
                        dispatcher.w = flow[fi][ti].w;
                        dispatcher.h = flow[fi][ti].h;
                        dispatcher.c = 1;
                        cmd.record_pipeline(rife_flow_tta_temporal_avg, bindings, constants, dispatcher);
                    }
                }

                // avg flow mask
                {
                    std::vector<ncnn::VkMat> bindings(8);
                    bindings[0] = flow[fi][0];
                    bindings[1] = flow[fi][1];
                    bindings[2] = flow[fi][2];
                    bindings[3] = flow[fi][3];
                    bindings[4] = flow[fi][4];
                    bindings[5] = flow[fi][5];
                    bindings[6] = flow[fi][6];
                    bindings[7] = flow[fi][7];

                    std::vector<ncnn::vk_constant_type> constants(3);
                    constants[0].i = flow[fi][0].w;
                    constants[1].i = flow[fi][0].h;
                    constants[2].i = flow[fi][0].cstep;

                    ncnn::VkMat dispatcher;
                    dispatcher.w = flow[fi][0].w;
                    dispatcher.h = flow[fi][0].h;
                    dispatcher.c = 1;
                    cmd.record_pipeline(rife_flow_tta_avg, bindings, constants, dispatcher);
                }
                {
                    std::vector<ncnn::VkMat> bindings(8);
                    bindings[0] = flow_reversed[fi][0];
                    bindings[1] = flow_reversed[fi][1];
                    bindings[2] = flow_reversed[fi][2];
                    bindings[3] = flow_reversed[fi][3];
                    bindings[4] = flow_reversed[fi][4];
                    bindings[5] = flow_reversed[fi][5];
                    bindings[6] = flow_reversed[fi][6];
                    bindings[7] = flow_reversed[fi][7];

                    std::vector<ncnn::vk_constant_type> constants(3);
                    constants[0].i = flow_reversed[fi][0].w;
                    constants[1].i = flow_reversed[fi][0].h;
                    constants[2].i = flow_reversed[fi][0].cstep;

                    ncnn::VkMat dispatcher;
                    dispatcher.w = flow_reversed[fi][0].w;
                    dispatcher.h = flow_reversed[fi][0].h;
                    dispatcher.c = 1;
                    cmd.record_pipeline(rife_flow_tta_avg, bindings, constants, dispatcher);
                }
            }

            ncnn::VkMat out_gpu_padded_reversed[8];
            for (int ti = 0; ti < 8; ti++)
            {
                {
                    // flownet
                    ncnn::Extractor ex = flownet.create_extractor();
                    ex.set_blob_vkallocator(blob_vkallocator);
                    ex.set_workspace_vkallocator(blob_vkallocator);
                    ex.set_staging_vkallocator(staging_vkallocator);

                    ex.input("in0", in0_gpu_padded[ti]);
                    ex.input("in1", in1_gpu_padded[ti]);
                    ex.input("in2", timestep_gpu_padded[ti / 4]);
                    ex.input("flow0", flow[0][ti]);
                    ex.input("flow1", flow[1][ti]);
                    ex.input("flow2", flow[2][ti]);
                    ex.input("flow3", flow[3][ti]);

                    ex.extract("out0", out_gpu_padded[ti], cmd);
                }

                {
                    ncnn::Extractor ex = flownet.create_extractor();
                    ex.set_blob_vkallocator(blob_vkallocator);
                    ex.set_workspace_vkallocator(blob_vkallocator);
                    ex.set_staging_vkallocator(staging_vkallocator);

                    ex.input("in0", in1_gpu_padded[ti]);
                    ex.input("in1", in0_gpu_padded[ti]);
                    ex.input("in2", timestep_gpu_padded_reversed[ti / 4]);
                    ex.input("flow0", flow_reversed[0][ti]);
                    ex.input("flow1", flow_reversed[1][ti]);
                    ex.input("flow2", flow_reversed[2][ti]);
                    ex.input("flow3", flow_reversed[3][ti]);

                    ex.extract("out0", out_gpu_padded_reversed[ti], cmd);
                }

                // merge output
                {
                    std::vector<ncnn::VkMat> bindings(2);
                    bindings[0] = out_gpu_padded[ti];
                    bindings[1] = out_gpu_padded_reversed[ti];

                    std::vector<ncnn::vk_constant_type> constants(3);
                    constants[0].i = out_gpu_padded[ti].w;
                    constants[1].i = out_gpu_padded[ti].h;
                    constants[2].i = out_gpu_padded[ti].cstep;

                    ncnn::VkMat dispatcher;
                    dispatcher.w = out_gpu_padded[ti].w;
                    dispatcher.h = out_gpu_padded[ti].h;
                    dispatcher.c = 3;
                    cmd.record_pipeline(rife_out_tta_temporal_avg, bindings, constants, dispatcher);
                }
            }
        }
        else
        {
            ncnn::VkMat flow[4][8];
            for (int fi = 0; fi < 4; fi++)
            {
                for (int ti = 0; ti < 8; ti++)
                {
                    // flownet flow mask
                    ncnn::Extractor ex = flownet.create_extractor();
                    ex.set_blob_vkallocator(blob_vkallocator);
                    ex.set_workspace_vkallocator(blob_vkallocator);
                    ex.set_staging_vkallocator(staging_vkallocator);

                    ex.input("in0", in0_gpu_padded[ti]);
                    ex.input("in1", in1_gpu_padded[ti]);
                    ex.input("in2", timestep_gpu_padded[ti / 4]);

                    // intentional fall through
                    switch (fi)
                    {
                    case 3: ex.input("flow2", flow[2][ti]);
                    case 2: ex.input("flow1", flow[1][ti]);
                    case 1: ex.input("flow0", flow[0][ti]);
                    default:
                    {
                        char tmp[16];
                        sprintf(tmp, "flow%d", fi);
                        ex.extract(tmp, flow[fi][ti], cmd);
                    }
                    }
                }

                // avg flow mask
                {
                    std::vector<ncnn::VkMat> bindings(8);
                    bindings[0] = flow[fi][0];
                    bindings[1] = flow[fi][1];
                    bindings[2] = flow[fi][2];
                    bindings[3] = flow[fi][3];
                    bindings[4] = flow[fi][4];
                    bindings[5] = flow[fi][5];
                    bindings[6] = flow[fi][6];
                    bindings[7] = flow[fi][7];

                    std::vector<ncnn::vk_constant_type> constants(3);
                    constants[0].i = flow[fi][0].w;
                    constants[1].i = flow[fi][0].h;
                    constants[2].i = flow[fi][0].cstep;

                    ncnn::VkMat dispatcher;
                    dispatcher.w = flow[fi][0].w;
                    dispatcher.h = flow[fi][0].h;
                    dispatcher.c = 1;
                    cmd.record_pipeline(rife_flow_tta_avg, bindings, constants, dispatcher);
                }
            }

            for (int ti = 0; ti < 8; ti++)
            {
                // flownet
                ncnn::Extractor ex = flownet.create_extractor();
                ex.set_blob_vkallocator(blob_vkallocator);
                ex.set_workspace_vkallocator(blob_vkallocator);
                ex.set_staging_vkallocator(staging_vkallocator);

                ex.input("in0", in0_gpu_padded[ti]);
                ex.input("in1", in1_gpu_padded[ti]);
                ex.input("in2", timestep_gpu_padded[ti / 4]);
                ex.input("flow0", flow[0][ti]);
                ex.input("flow1", flow[1][ti]);
                ex.input("flow2", flow[2][ti]);
                ex.input("flow3", flow[3][ti]);

                ex.extract("out0", out_gpu_padded[ti], cmd);
            }
        }

        if (opt.use_fp16_storage && opt.use_int8_storage)
        {
            out_gpu.create(w, h, (size_t)channels, 1, blob_vkallocator);
        }
        else
        {
            out_gpu.create(w, h, channels, (size_t)4u, 1, blob_vkallocator);
        }

        // postproc
        {
            std::vector<ncnn::VkMat> bindings(9);
            bindings[0] = out_gpu_padded[0];
            bindings[1] = out_gpu_padded[1];
            bindings[2] = out_gpu_padded[2];
            bindings[3] = out_gpu_padded[3];
            bindings[4] = out_gpu_padded[4];
            bindings[5] = out_gpu_padded[5];
            bindings[6] = out_gpu_padded[6];
            bindings[7] = out_gpu_padded[7];
            bindings[8] = out_gpu;

            std::vector<ncnn::vk_constant_type> constants(6);
            constants[0].i = out_gpu_padded[0].w;
            constants[1].i = out_gpu_padded[0].h;
            constants[2].i = out_gpu_padded[0].cstep;
            constants[3].i = out_gpu.w;
            constants[4].i = out_gpu.h;
            constants[5].i = out_gpu.cstep;

            cmd.record_pipeline(rife_postproc, bindings, constants, out_gpu);
        }
    }
    else
    {
        // preproc
        ncnn::VkMat in0_gpu_padded;
        ncnn::VkMat in1_gpu_padded;
        ncnn::VkMat timestep_gpu_padded;
        {
            in0_gpu_padded.create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);

            std::vector<ncnn::VkMat> bindings(2);
            bindings[0] = in0_gpu;
            bindings[1] = in0_gpu_padded;

            std::vector<ncnn::vk_constant_type> constants(6);
            constants[0].i = in0_gpu.w;
            constants[1].i = in0_gpu.h;
            constants[2].i = in0_gpu.cstep;
            constants[3].i = in0_gpu_padded.w;
            constants[4].i = in0_gpu_padded.h;
            constants[5].i = in0_gpu_padded.cstep;

            cmd.record_pipeline(rife_preproc, bindings, constants, in0_gpu_padded);
        }
        {
            in1_gpu_padded.create(w_padded, h_padded, 3, in_out_tile_elemsize, 1, blob_vkallocator);

            std::vector<ncnn::VkMat> bindings(2);
            bindings[0] = in1_gpu;
            bindings[1] = in1_gpu_padded;

            std::vector<ncnn::vk_constant_type> constants(6);
            constants[0].i = in1_gpu.w;
            constants[1].i = in1_gpu.h;
            constants[2].i = in1_gpu.cstep;
            constants[3].i = in1_gpu_padded.w;
            constants[4].i = in1_gpu_padded.h;
            constants[5].i = in1_gpu_padded.cstep;

            cmd.record_pipeline(rife_preproc, bindings, constants, in1_gpu_padded);
        }
        {
            timestep_gpu_padded.create(w_padded, h_padded, 1, in_out_tile_elemsize, 1, blob_vkallocator);

            std::vector<ncnn::VkMat> bindings(1);
            bindings[0] = timestep_gpu_padded;

            std::vector<ncnn::vk_constant_type> constants(4);
            constants[0].i = timestep_gpu_padded.w;
            constants[1].i = timestep_gpu_padded.h;
            constants[2].i = timestep_gpu_padded.cstep;
            constants[3].f = timestep;

            cmd.record_pipeline(rife_v4_timestep, bindings, constants, timestep_gpu_padded);
        }

        ncnn::VkMat out_gpu_padded;
        if (tta_temporal_mode)
        {
            ncnn::VkMat timestep_gpu_padded_reversed;
            {
                timestep_gpu_padded_reversed.create(w_padded, h_padded, 1, in_out_tile_elemsize, 1, blob_vkallocator);

                std::vector<ncnn::VkMat> bindings(1);
                bindings[0] = timestep_gpu_padded_reversed;

                std::vector<ncnn::vk_constant_type> constants(4);
                constants[0].i = timestep_gpu_padded_reversed.w;
                constants[1].i = timestep_gpu_padded_reversed.h;
                constants[2].i = timestep_gpu_padded_reversed.cstep;
                constants[3].f = 1.f - timestep;

                cmd.record_pipeline(rife_v4_timestep, bindings, constants, timestep_gpu_padded_reversed);
            }

            ncnn::VkMat flow[4];
            ncnn::VkMat flow_reversed[4];
            for (int fi = 0; fi < 4; fi++)
            {
                {
                    // flownet flow mask
                    ncnn::Extractor ex = flownet.create_extractor();
                    ex.set_blob_vkallocator(blob_vkallocator);
                    ex.set_workspace_vkallocator(blob_vkallocator);
                    ex.set_staging_vkallocator(staging_vkallocator);

                    ex.input("in0", in0_gpu_padded);
                    ex.input("in1", in1_gpu_padded);
                    ex.input("in2", timestep_gpu_padded);

                    // intentional fall through
                    switch (fi)
                    {
                    case 3: ex.input("flow2", flow[2]);
                    case 2: ex.input("flow1", flow[1]);
                    case 1: ex.input("flow0", flow[0]);
                    default:
                    {
                        char tmp[16];
                        sprintf(tmp, "flow%d", fi);
                        ex.extract(tmp, flow[fi], cmd);
                    }
                    }
                }

                {
                    // flownet flow mask reversed
                    ncnn::Extractor ex = flownet.create_extractor();
                    ex.set_blob_vkallocator(blob_vkallocator);
                    ex.set_workspace_vkallocator(blob_vkallocator);
                    ex.set_staging_vkallocator(staging_vkallocator);

                    ex.input("in0", in1_gpu_padded);
                    ex.input("in1", in0_gpu_padded);
                    ex.input("in2", timestep_gpu_padded_reversed);

                    // intentional fall through
                    switch (fi)
                    {
                    case 3: ex.input("flow2", flow_reversed[2]);
                    case 2: ex.input("flow1", flow_reversed[1]);
                    case 1: ex.input("flow0", flow_reversed[0]);
                    default:
                    {
                        char tmp[16];
                        sprintf(tmp, "flow%d", fi);
                        ex.extract(tmp, flow_reversed[fi], cmd);
                    }
                    }
                }

                // merge flow and flow_reversed
                {
                    std::vector<ncnn::VkMat> bindings(2);
                    bindings[0] = flow[fi];
                    bindings[1] = flow_reversed[fi];

                    std::vector<ncnn::vk_constant_type> constants(3);
                    constants[0].i = flow[fi].w;
                    constants[1].i = flow[fi].h;
                    constants[2].i = flow[fi].cstep;

                    ncnn::VkMat dispatcher;
                    dispatcher.w = flow[fi].w;
                    dispatcher.h = flow[fi].h;
                    dispatcher.c = 1;
                    cmd.record_pipeline(rife_flow_tta_temporal_avg, bindings, constants, dispatcher);
                }
            }

            {
                // flownet
                ncnn::Extractor ex = flownet.create_extractor();
                ex.set_blob_vkallocator(blob_vkallocator);
                ex.set_workspace_vkallocator(blob_vkallocator);
                ex.set_staging_vkallocator(staging_vkallocator);

                ex.input("in0", in0_gpu_padded);
                ex.input("in1", in1_gpu_padded);
                ex.input("in2", timestep_gpu_padded);
                ex.input("flow0", flow[0]);
                ex.input("flow1", flow[1]);
                ex.input("flow2", flow[2]);
                ex.input("flow3", flow[3]);

                ex.extract("out0", out_gpu_padded, cmd);
            }

            ncnn::VkMat out_gpu_padded_reversed;
            {
                ncnn::Extractor ex = flownet.create_extractor();
                ex.set_blob_vkallocator(blob_vkallocator);
                ex.set_workspace_vkallocator(blob_vkallocator);
                ex.set_staging_vkallocator(staging_vkallocator);

                ex.input("in0", in1_gpu_padded);
                ex.input("in1", in0_gpu_padded);
                ex.input("in2", timestep_gpu_padded_reversed);
                ex.input("flow0", flow_reversed[0]);
                ex.input("flow1", flow_reversed[1]);
                ex.input("flow2", flow_reversed[2]);
                ex.input("flow3", flow_reversed[3]);

                ex.extract("out0", out_gpu_padded_reversed, cmd);
            }

            // merge output
            {
                std::vector<ncnn::VkMat> bindings(2);
                bindings[0] = out_gpu_padded;
                bindings[1] = out_gpu_padded_reversed;

                std::vector<ncnn::vk_constant_type> constants(3);
                constants[0].i = out_gpu_padded.w;
                constants[1].i = out_gpu_padded.h;
                constants[2].i = out_gpu_padded.cstep;

                ncnn::VkMat dispatcher;
                dispatcher.w = out_gpu_padded.w;
                dispatcher.h = out_gpu_padded.h;
                dispatcher.c = 3;
                cmd.record_pipeline(rife_out_tta_temporal_avg, bindings, constants, dispatcher);
            }
        }
        else
        {
            // flownet
            ncnn::Extractor ex = flownet.create_extractor();
            ex.set_blob_vkallocator(blob_vkallocator);
            ex.set_workspace_vkallocator(blob_vkallocator);
            ex.set_staging_vkallocator(staging_vkallocator);

            ex.input("in0", in0_gpu_padded);
            ex.input("in1", in1_gpu_padded);
            ex.input("in2", timestep_gpu_padded);
            ex.extract("out0", out_gpu_padded, cmd);
        }

        if (opt.use_fp16_storage && opt.use_int8_storage)
        {
            out_gpu.create(w, h, (size_t)channels, 1, blob_vkallocator);
        }
        else
        {
            out_gpu.create(w, h, channels, (size_t)4u, 1, blob_vkallocator);
        }

        // postproc
        {
            std::vector<ncnn::VkMat> bindings(2);
            bindings[0] = out_gpu_padded;
            bindings[1] = out_gpu;

            std::vector<ncnn::vk_constant_type> constants(6);
            constants[0].i = out_gpu_padded.w;
            constants[1].i = out_gpu_padded.h;
            constants[2].i = out_gpu_padded.cstep;
            constants[3].i = out_gpu.w;
            constants[4].i = out_gpu.h;
            constants[5].i = out_gpu.cstep;

            cmd.record_pipeline(rife_postproc, bindings, constants, out_gpu);
        }
    }

    // download
    {
        ncnn::Mat out;

        if (opt.use_fp16_storage && opt.use_int8_storage)
        {
            out = ncnn::Mat(out_gpu.w, out_gpu.h, (unsigned char*)outimage.data, (size_t)channels, 1);
        }

        cmd.record_clone(out_gpu, out, opt);

        cmd.submit_and_wait();

        if (!(opt.use_fp16_storage && opt.use_int8_storage))
        {
#if _WIN32
            out.to_pixels((unsigned char*)outimage.data, ncnn::Mat::PIXEL_RGB2BGR);
#else
            out.to_pixels((unsigned char*)outimage.data, ncnn::Mat::PIXEL_RGB);
#endif
        }
    }

    vkdev->reclaim_blob_allocator(blob_vkallocator);
    vkdev->reclaim_staging_allocator(staging_vkallocator);

    return 0;
}

int RIFE::process_v4_cpu(const ncnn::Mat& in0image, const ncnn::Mat& in1image, float timestep, ncnn::Mat& outimage) const
{
    if (timestep == 0.f)
    {
        outimage = in0image;
        return 0;
    }

    if (timestep == 1.f)
    {
        outimage = in1image;
        return 0;
    }

    const unsigned char* pixel0data = (const unsigned char*)in0image.data;
    const unsigned char* pixel1data = (const unsigned char*)in1image.data;
    const int w = in0image.w;
    const int h = in0image.h;
    const int channels = 3;//in0image.elempack;

//     fprintf(stderr, "%d x %d\n", w, h);

    ncnn::Option opt = flownet.opt;

    // pad to 32n
    int w_padded = (w + 31) / 32 * 32;
    int h_padded = (h + 31) / 32 * 32;

    ncnn::Mat in0;
    ncnn::Mat in1;
    {
#if _WIN32
        in0 = ncnn::Mat::from_pixels(pixel0data, ncnn::Mat::PIXEL_BGR2RGB, w, h);
        in1 = ncnn::Mat::from_pixels(pixel1data, ncnn::Mat::PIXEL_BGR2RGB, w, h);
#else
        in0 = ncnn::Mat::from_pixels(pixel0data, ncnn::Mat::PIXEL_RGB, w, h);
        in1 = ncnn::Mat::from_pixels(pixel1data, ncnn::Mat::PIXEL_RGB, w, h);
#endif
    }

    ncnn::Mat out;

    if (tta_mode)
    {
        // preproc and border padding
        ncnn::Mat in0_padded[8];
        ncnn::Mat in1_padded[8];
        ncnn::Mat timestep_padded[2];
        {
            in0_padded[0].create(w_padded, h_padded, 3);
            for (int q = 0; q < 3; q++)
            {
                float* outptr = in0_padded[0].channel(q);

                int i = 0;
                for (; i < h; i++)
                {
                    const float* ptr = in0.channel(q).row(i);

                    int j = 0;
                    for (; j < w; j++)
                    {
                        *outptr++ = *ptr++ * (1 / 255.f);
                    }
                    for (; j < w_padded; j++)
                    {
                        *outptr++ = 0.f;
                    }
                }
                for (; i < h_padded; i++)
                {
                    for (int j = 0; j < w_padded; j++)
                    {
                        *outptr++ = 0.f;
                    }
                }
            }
        }
        {
            in1_padded[0].create(w_padded, h_padded, 3);
            for (int q = 0; q < 3; q++)
            {
                float* outptr = in1_padded[0].channel(q);

                int i = 0;
                for (; i < h; i++)
                {
                    const float* ptr = in1.channel(q).row(i);

                    int j = 0;
                    for (; j < w; j++)
                    {
                        *outptr++ = *ptr++ * (1 / 255.f);
                    }
                    for (; j < w_padded; j++)
                    {
                        *outptr++ = 0.f;
                    }
                }
                for (; i < h_padded; i++)
                {
                    for (int j = 0; j < w_padded; j++)
                    {
                        *outptr++ = 0.f;
                    }
                }
            }
        }
        {
            timestep_padded[0].create(w_padded, h_padded, 1);
            timestep_padded[1].create(h_padded, w_padded, 1);
            timestep_padded[0].fill(timestep);
            timestep_padded[1].fill(timestep);
        }

        // the other 7 directions
        {
            in0_padded[1].create(w_padded, h_padded, 3);
            in0_padded[2].create(w_padded, h_padded, 3);
            in0_padded[3].create(w_padded, h_padded, 3);
            in0_padded[4].create(h_padded, w_padded, 3);
            in0_padded[5].create(h_padded, w_padded, 3);
            in0_padded[6].create(h_padded, w_padded, 3);
            in0_padded[7].create(h_padded, w_padded, 3);

            for (int q = 0; q < 3; q++)
            {
                const ncnn::Mat in0_padded_0 = in0_padded[0].channel(q);
                ncnn::Mat in0_padded_1 = in0_padded[1].channel(q);
                ncnn::Mat in0_padded_2 = in0_padded[2].channel(q);
                ncnn::Mat in0_padded_3 = in0_padded[3].channel(q);
                ncnn::Mat in0_padded_4 = in0_padded[4].channel(q);
                ncnn::Mat in0_padded_5 = in0_padded[5].channel(q);
                ncnn::Mat in0_padded_6 = in0_padded[6].channel(q);
                ncnn::Mat in0_padded_7 = in0_padded[7].channel(q);

                for (int i = 0; i < h_padded; i++)
                {
                    const float* outptr0 = in0_padded_0.row(i);
                    float* outptr1 = in0_padded_1.row(i) + w_padded - 1;
                    float* outptr2 = in0_padded_2.row(h_padded - 1 - i) + w_padded - 1;
                    float* outptr3 = in0_padded_3.row(h_padded - 1 - i);

                    for (int j = 0; j < w_padded; j++)
                    {
                        float* outptr4 = in0_padded_4.row(j) + i;
                        float* outptr5 = in0_padded_5.row(j) + h_padded - 1 - i;
                        float* outptr6 = in0_padded_6.row(w_padded - 1 - j) + h_padded - 1 - i;
                        float* outptr7 = in0_padded_7.row(w_padded - 1 - j) + i;

                        float v = *outptr0++;

                        *outptr1-- = v;
                        *outptr2-- = v;
                        *outptr3++ = v;
                        *outptr4 = v;
                        *outptr5 = v;
                        *outptr6 = v;
                        *outptr7 = v;
                    }
                }
            }
        }
        {
            in1_padded[1].create(w_padded, h_padded, 3);
            in1_padded[2].create(w_padded, h_padded, 3);
            in1_padded[3].create(w_padded, h_padded, 3);
            in1_padded[4].create(h_padded, w_padded, 3);
            in1_padded[5].create(h_padded, w_padded, 3);
            in1_padded[6].create(h_padded, w_padded, 3);
            in1_padded[7].create(h_padded, w_padded, 3);

            for (int q = 0; q < 3; q++)
            {
                const ncnn::Mat in1_padded_0 = in1_padded[0].channel(q);
                ncnn::Mat in1_padded_1 = in1_padded[1].channel(q);
                ncnn::Mat in1_padded_2 = in1_padded[2].channel(q);
                ncnn::Mat in1_padded_3 = in1_padded[3].channel(q);
                ncnn::Mat in1_padded_4 = in1_padded[4].channel(q);
                ncnn::Mat in1_padded_5 = in1_padded[5].channel(q);
                ncnn::Mat in1_padded_6 = in1_padded[6].channel(q);
                ncnn::Mat in1_padded_7 = in1_padded[7].channel(q);

                for (int i = 0; i < h_padded; i++)
                {
                    const float* outptr0 = in1_padded_0.row(i);
                    float* outptr1 = in1_padded_1.row(i) + w_padded - 1;
                    float* outptr2 = in1_padded_2.row(h_padded - 1 - i) + w_padded - 1;
                    float* outptr3 = in1_padded_3.row(h_padded - 1 - i);

                    for (int j = 0; j < w_padded; j++)
                    {
                        float* outptr4 = in1_padded_4.row(j) + i;
                        float* outptr5 = in1_padded_5.row(j) + h_padded - 1 - i;
                        float* outptr6 = in1_padded_6.row(w_padded - 1 - j) + h_padded - 1 - i;
                        float* outptr7 = in1_padded_7.row(w_padded - 1 - j) + i;

                        float v = *outptr0++;

                        *outptr1-- = v;
                        *outptr2-- = v;
                        *outptr3++ = v;
                        *outptr4 = v;
                        *outptr5 = v;
                        *outptr6 = v;
                        *outptr7 = v;
                    }
                }
            }
        }

        ncnn::Mat out_padded[8];
        ncnn::Mat out_padded_reversed[8];
        if (tta_temporal_mode)
        {
            ncnn::Mat timestep_padded_reversed[2];
            timestep_padded_reversed[0].create(w_padded, h_padded, 1);
            timestep_padded_reversed[1].create(h_padded, w_padded, 1);
            timestep_padded_reversed[0].fill(1.f - timestep);
            timestep_padded_reversed[1].fill(1.f - timestep);

            ncnn::Mat flow[4][8];
            ncnn::Mat flow_reversed[4][8];
            for (int fi = 0; fi < 4; fi++)
            {
                for (int ti = 0; ti < 8; ti++)
                {
                    // flownet flow mask
                    {
                        ncnn::Extractor ex = flownet.create_extractor();

                        ex.input("in0", in0_padded[ti]);
                        ex.input("in1", in1_padded[ti]);
                        ex.input("in2", timestep_padded[ti / 4]);

                        // intentional fall through
                        switch (fi)
                        {
                        case 3: ex.input("flow2", flow[2][ti]);
                        case 2: ex.input("flow1", flow[1][ti]);
                        case 1: ex.input("flow0", flow[0][ti]);
                        default:
                        {
                            char tmp[16];
                            sprintf(tmp, "flow%d", fi);
                            ex.extract(tmp, flow[fi][ti]);
                        }
                        }
                    }

                    // flownet flow mask reversed
                    {
                        ncnn::Extractor ex = flownet.create_extractor();

                        ex.input("in0", in1_padded[ti]);
                        ex.input("in1", in0_padded[ti]);
                        ex.input("in2", timestep_padded_reversed[ti / 4]);

                        // intentional fall through
                        switch (fi)
                        {
                        case 3: ex.input("flow2", flow_reversed[2][ti]);
                        case 2: ex.input("flow1", flow_reversed[1][ti]);
                        case 1: ex.input("flow0", flow_reversed[0][ti]);
                        default:
                        {
                            char tmp[16];
                            sprintf(tmp, "flow%d", fi);
                            ex.extract(tmp, flow_reversed[fi][ti]);
                        }
                        }
                    }

                    // merge flow and flow_reversed
                    {
                        float* flow_x = flow[fi][ti].channel(0);
                        float* flow_y = flow[fi][ti].channel(1);
                        float* flow_z = flow[fi][ti].channel(2);
                        float* flow_w = flow[fi][ti].channel(3);
                        float* flow_m = flow[fi][ti].channel(4);
                        float* flow_reversed_x = flow_reversed[fi][ti].channel(0);
                        float* flow_reversed_y = flow_reversed[fi][ti].channel(1);
                        float* flow_reversed_z = flow_reversed[fi][ti].channel(2);
                        float* flow_reversed_w = flow_reversed[fi][ti].channel(3);
                        float* flow_reversed_m = flow_reversed[fi][ti].channel(4);

                        for (int i = 0; i < flow[fi][ti].h; i++)
                        {
                            for (int j = 0; j < flow[fi][ti].w; j++)
                            {
                                float x = (*flow_x + *flow_reversed_z) * 0.5f;
                                float y = (*flow_y + *flow_reversed_w) * 0.5f;
                                float z = (*flow_z + *flow_reversed_x) * 0.5f;
                                float w = (*flow_w + *flow_reversed_y) * 0.5f;
                                float m = (*flow_m - *flow_reversed_m) * 0.5f;

                                *flow_x++ = x;
                                *flow_y++ = y;
                                *flow_z++ = z;
                                *flow_w++ = w;
                                *flow_m++ = m;
                                *flow_reversed_x++ = z;
                                *flow_reversed_y++ = w;
                                *flow_reversed_z++ = x;
                                *flow_reversed_w++ = y;
                                *flow_reversed_m++ = -m;
                            }
                        }
                    }
                }

                // avg flow mask
                {
                    ncnn::Mat flow_x0 = flow[fi][0].channel(0);
                    ncnn::Mat flow_x1 = flow[fi][1].channel(0);
                    ncnn::Mat flow_x2 = flow[fi][2].channel(0);
                    ncnn::Mat flow_x3 = flow[fi][3].channel(0);
                    ncnn::Mat flow_x4 = flow[fi][4].channel(0);
                    ncnn::Mat flow_x5 = flow[fi][5].channel(0);
                    ncnn::Mat flow_x6 = flow[fi][6].channel(0);
                    ncnn::Mat flow_x7 = flow[fi][7].channel(0);

                    ncnn::Mat flow_y0 = flow[fi][0].channel(1);
                    ncnn::Mat flow_y1 = flow[fi][1].channel(1);
                    ncnn::Mat flow_y2 = flow[fi][2].channel(1);
                    ncnn::Mat flow_y3 = flow[fi][3].channel(1);
                    ncnn::Mat flow_y4 = flow[fi][4].channel(1);
                    ncnn::Mat flow_y5 = flow[fi][5].channel(1);
                    ncnn::Mat flow_y6 = flow[fi][6].channel(1);
                    ncnn::Mat flow_y7 = flow[fi][7].channel(1);

                    ncnn::Mat flow_z0 = flow[fi][0].channel(2);
                    ncnn::Mat flow_z1 = flow[fi][1].channel(2);
                    ncnn::Mat flow_z2 = flow[fi][2].channel(2);
                    ncnn::Mat flow_z3 = flow[fi][3].channel(2);
                    ncnn::Mat flow_z4 = flow[fi][4].channel(2);
                    ncnn::Mat flow_z5 = flow[fi][5].channel(2);
                    ncnn::Mat flow_z6 = flow[fi][6].channel(2);
                    ncnn::Mat flow_z7 = flow[fi][7].channel(2);

                    ncnn::Mat flow_w0 = flow[fi][0].channel(3);
                    ncnn::Mat flow_w1 = flow[fi][1].channel(3);
                    ncnn::Mat flow_w2 = flow[fi][2].channel(3);
                    ncnn::Mat flow_w3 = flow[fi][3].channel(3);
                    ncnn::Mat flow_w4 = flow[fi][4].channel(3);
                    ncnn::Mat flow_w5 = flow[fi][5].channel(3);
                    ncnn::Mat flow_w6 = flow[fi][6].channel(3);
                    ncnn::Mat flow_w7 = flow[fi][7].channel(3);

                    ncnn::Mat flow_m0 = flow[fi][0].channel(4);
                    ncnn::Mat flow_m1 = flow[fi][1].channel(4);
                    ncnn::Mat flow_m2 = flow[fi][2].channel(4);
                    ncnn::Mat flow_m3 = flow[fi][3].channel(4);
                    ncnn::Mat flow_m4 = flow[fi][4].channel(4);
                    ncnn::Mat flow_m5 = flow[fi][5].channel(4);
                    ncnn::Mat flow_m6 = flow[fi][6].channel(4);
                    ncnn::Mat flow_m7 = flow[fi][7].channel(4);

                    for (int i = 0; i < flow_x0.h; i++)
                    {
                        float* x0 = flow_x0.row(i);
                        float* x1 = flow_x1.row(i) + flow_x0.w - 1;
                        float* x2 = flow_x2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                        float* x3 = flow_x3.row(flow_x0.h - 1 - i);

                        float* y0 = flow_y0.row(i);
                        float* y1 = flow_y1.row(i) + flow_x0.w - 1;
                        float* y2 = flow_y2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                        float* y3 = flow_y3.row(flow_x0.h - 1 - i);

                        float* z0 = flow_z0.row(i);
                        float* z1 = flow_z1.row(i) + flow_x0.w - 1;
                        float* z2 = flow_z2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                        float* z3 = flow_z3.row(flow_x0.h - 1 - i);

                        float* w0 = flow_w0.row(i);
                        float* w1 = flow_w1.row(i) + flow_x0.w - 1;
                        float* w2 = flow_w2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                        float* w3 = flow_w3.row(flow_x0.h - 1 - i);

                        float* m0 = flow_m0.row(i);
                        float* m1 = flow_m1.row(i) + flow_x0.w - 1;
                        float* m2 = flow_m2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                        float* m3 = flow_m3.row(flow_x0.h - 1 - i);

                        for (int j = 0; j < flow_x0.w; j++)
                        {
                            float* x4 = flow_x4.row(j) + i;
                            float* x5 = flow_x5.row(j) + flow_x0.h - 1 - i;
                            float* x6 = flow_x6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                            float* x7 = flow_x7.row(flow_x0.w - 1 - j) + i;

                            float* y4 = flow_y4.row(j) + i;
                            float* y5 = flow_y5.row(j) + flow_x0.h - 1 - i;
                            float* y6 = flow_y6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                            float* y7 = flow_y7.row(flow_x0.w - 1 - j) + i;

                            float* z4 = flow_z4.row(j) + i;
                            float* z5 = flow_z5.row(j) + flow_x0.h - 1 - i;
                            float* z6 = flow_z6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                            float* z7 = flow_z7.row(flow_x0.w - 1 - j) + i;

                            float* w4 = flow_w4.row(j) + i;
                            float* w5 = flow_w5.row(j) + flow_x0.h - 1 - i;
                            float* w6 = flow_w6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                            float* w7 = flow_w7.row(flow_x0.w - 1 - j) + i;

                            float* m4 = flow_m4.row(j) + i;
                            float* m5 = flow_m5.row(j) + flow_x0.h - 1 - i;
                            float* m6 = flow_m6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                            float* m7 = flow_m7.row(flow_x0.w - 1 - j) + i;

                            float x = (*x0 + -*x1 + -*x2 + *x3 + *y4 + *y5 + -*y6 + -*y7) * 0.125f;
                            float y = (*y0 + *y1 + -*y2 + -*y3 + *x4 + -*x5 + -*x6 + *x7) * 0.125f;
                            float z = (*z0 + -*z1 + -*z2 + *z3 + *w4 + *w5 + -*w6 + -*w7) * 0.125f;
                            float w = (*w0 + *w1 + -*w2 + -*w3 + *z4 + -*z5 + -*z6 + *z7) * 0.125f;
                            float m = (*m0 + *m1 + *m2 + *m3 + *m4 + *m5 + *m6 + *m7) * 0.125f;

                            *x0++ = x;
                            *x1-- = -x;
                            *x2-- = -x;
                            *x3++ = x;
                            *x4 = y;
                            *x5 = -y;
                            *x6 = -y;
                            *x7 = y;

                            *y0++ = y;
                            *y1-- = y;
                            *y2-- = -y;
                            *y3++ = -y;
                            *y4 = x;
                            *y5 = x;
                            *y6 = -x;
                            *y7 = -x;

                            *z0++ = z;
                            *z1-- = -z;
                            *z2-- = -z;
                            *z3++ = z;
                            *z4 = w;
                            *z5 = -w;
                            *z6 = -w;
                            *z7 = w;

                            *w0++ = w;
                            *w1-- = w;
                            *w2-- = -w;
                            *w3++ = -w;
                            *w4 = z;
                            *w5 = z;
                            *w6 = -z;
                            *w7 = -z;

                            *m0++ = m;
                            *m1-- = m;
                            *m2-- = m;
                            *m3++ = m;
                            *m4 = m;
                            *m5 = m;
                            *m6 = m;
                            *m7 = m;
                        }
                    }
                }
                {
                    ncnn::Mat flow_x0 = flow_reversed[fi][0].channel(0);
                    ncnn::Mat flow_x1 = flow_reversed[fi][1].channel(0);
                    ncnn::Mat flow_x2 = flow_reversed[fi][2].channel(0);
                    ncnn::Mat flow_x3 = flow_reversed[fi][3].channel(0);
                    ncnn::Mat flow_x4 = flow_reversed[fi][4].channel(0);
                    ncnn::Mat flow_x5 = flow_reversed[fi][5].channel(0);
                    ncnn::Mat flow_x6 = flow_reversed[fi][6].channel(0);
                    ncnn::Mat flow_x7 = flow_reversed[fi][7].channel(0);

                    ncnn::Mat flow_y0 = flow_reversed[fi][0].channel(1);
                    ncnn::Mat flow_y1 = flow_reversed[fi][1].channel(1);
                    ncnn::Mat flow_y2 = flow_reversed[fi][2].channel(1);
                    ncnn::Mat flow_y3 = flow_reversed[fi][3].channel(1);
                    ncnn::Mat flow_y4 = flow_reversed[fi][4].channel(1);
                    ncnn::Mat flow_y5 = flow_reversed[fi][5].channel(1);
                    ncnn::Mat flow_y6 = flow_reversed[fi][6].channel(1);
                    ncnn::Mat flow_y7 = flow_reversed[fi][7].channel(1);

                    ncnn::Mat flow_z0 = flow_reversed[fi][0].channel(2);
                    ncnn::Mat flow_z1 = flow_reversed[fi][1].channel(2);
                    ncnn::Mat flow_z2 = flow_reversed[fi][2].channel(2);
                    ncnn::Mat flow_z3 = flow_reversed[fi][3].channel(2);
                    ncnn::Mat flow_z4 = flow_reversed[fi][4].channel(2);
                    ncnn::Mat flow_z5 = flow_reversed[fi][5].channel(2);
                    ncnn::Mat flow_z6 = flow_reversed[fi][6].channel(2);
                    ncnn::Mat flow_z7 = flow_reversed[fi][7].channel(2);

                    ncnn::Mat flow_w0 = flow_reversed[fi][0].channel(3);
                    ncnn::Mat flow_w1 = flow_reversed[fi][1].channel(3);
                    ncnn::Mat flow_w2 = flow_reversed[fi][2].channel(3);
                    ncnn::Mat flow_w3 = flow_reversed[fi][3].channel(3);
                    ncnn::Mat flow_w4 = flow_reversed[fi][4].channel(3);
                    ncnn::Mat flow_w5 = flow_reversed[fi][5].channel(3);
                    ncnn::Mat flow_w6 = flow_reversed[fi][6].channel(3);
                    ncnn::Mat flow_w7 = flow_reversed[fi][7].channel(3);

                    ncnn::Mat flow_m0 = flow_reversed[fi][0].channel(4);
                    ncnn::Mat flow_m1 = flow_reversed[fi][1].channel(4);
                    ncnn::Mat flow_m2 = flow_reversed[fi][2].channel(4);
                    ncnn::Mat flow_m3 = flow_reversed[fi][3].channel(4);
                    ncnn::Mat flow_m4 = flow_reversed[fi][4].channel(4);
                    ncnn::Mat flow_m5 = flow_reversed[fi][5].channel(4);
                    ncnn::Mat flow_m6 = flow_reversed[fi][6].channel(4);
                    ncnn::Mat flow_m7 = flow_reversed[fi][7].channel(4);

                    for (int i = 0; i < flow_x0.h; i++)
                    {
                        float* x0 = flow_x0.row(i);
                        float* x1 = flow_x1.row(i) + flow_x0.w - 1;
                        float* x2 = flow_x2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                        float* x3 = flow_x3.row(flow_x0.h - 1 - i);

                        float* y0 = flow_y0.row(i);
                        float* y1 = flow_y1.row(i) + flow_x0.w - 1;
                        float* y2 = flow_y2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                        float* y3 = flow_y3.row(flow_x0.h - 1 - i);

                        float* z0 = flow_z0.row(i);
                        float* z1 = flow_z1.row(i) + flow_x0.w - 1;
                        float* z2 = flow_z2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                        float* z3 = flow_z3.row(flow_x0.h - 1 - i);

                        float* w0 = flow_w0.row(i);
                        float* w1 = flow_w1.row(i) + flow_x0.w - 1;
                        float* w2 = flow_w2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                        float* w3 = flow_w3.row(flow_x0.h - 1 - i);

                        float* m0 = flow_m0.row(i);
                        float* m1 = flow_m1.row(i) + flow_x0.w - 1;
                        float* m2 = flow_m2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                        float* m3 = flow_m3.row(flow_x0.h - 1 - i);

                        for (int j = 0; j < flow_x0.w; j++)
                        {
                            float* x4 = flow_x4.row(j) + i;
                            float* x5 = flow_x5.row(j) + flow_x0.h - 1 - i;
                            float* x6 = flow_x6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                            float* x7 = flow_x7.row(flow_x0.w - 1 - j) + i;

                            float* y4 = flow_y4.row(j) + i;
                            float* y5 = flow_y5.row(j) + flow_x0.h - 1 - i;
                            float* y6 = flow_y6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                            float* y7 = flow_y7.row(flow_x0.w - 1 - j) + i;

                            float* z4 = flow_z4.row(j) + i;
                            float* z5 = flow_z5.row(j) + flow_x0.h - 1 - i;
                            float* z6 = flow_z6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                            float* z7 = flow_z7.row(flow_x0.w - 1 - j) + i;

                            float* w4 = flow_w4.row(j) + i;
                            float* w5 = flow_w5.row(j) + flow_x0.h - 1 - i;
                            float* w6 = flow_w6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                            float* w7 = flow_w7.row(flow_x0.w - 1 - j) + i;

                            float* m4 = flow_m4.row(j) + i;
                            float* m5 = flow_m5.row(j) + flow_x0.h - 1 - i;
                            float* m6 = flow_m6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                            float* m7 = flow_m7.row(flow_x0.w - 1 - j) + i;

                            float x = (*x0 + -*x1 + -*x2 + *x3 + *y4 + *y5 + -*y6 + -*y7) * 0.125f;
                            float y = (*y0 + *y1 + -*y2 + -*y3 + *x4 + -*x5 + -*x6 + *x7) * 0.125f;
                            float z = (*z0 + -*z1 + -*z2 + *z3 + *w4 + *w5 + -*w6 + -*w7) * 0.125f;
                            float w = (*w0 + *w1 + -*w2 + -*w3 + *z4 + -*z5 + -*z6 + *z7) * 0.125f;
                            float m = (*m0 + *m1 + *m2 + *m3 + *m4 + *m5 + *m6 + *m7) * 0.125f;

                            *x0++ = x;
                            *x1-- = -x;
                            *x2-- = -x;
                            *x3++ = x;
                            *x4 = y;
                            *x5 = -y;
                            *x6 = -y;
                            *x7 = y;

                            *y0++ = y;
                            *y1-- = y;
                            *y2-- = -y;
                            *y3++ = -y;
                            *y4 = x;
                            *y5 = x;
                            *y6 = -x;
                            *y7 = -x;

                            *z0++ = z;
                            *z1-- = -z;
                            *z2-- = -z;
                            *z3++ = z;
                            *z4 = w;
                            *z5 = -w;
                            *z6 = -w;
                            *z7 = w;

                            *w0++ = w;
                            *w1-- = w;
                            *w2-- = -w;
                            *w3++ = -w;
                            *w4 = z;
                            *w5 = z;
                            *w6 = -z;
                            *w7 = -z;

                            *m0++ = m;
                            *m1-- = m;
                            *m2-- = m;
                            *m3++ = m;
                            *m4 = m;
                            *m5 = m;
                            *m6 = m;
                            *m7 = m;
                        }
                    }
                }
            }

            for (int ti = 0; ti < 8; ti++)
            {
                // flownet
                {
                    ncnn::Extractor ex = flownet.create_extractor();

                    ex.input("in0", in0_padded[ti]);
                    ex.input("in1", in1_padded[ti]);
                    ex.input("in2", timestep_padded[ti / 4]);
                    ex.input("flow0", flow[0][ti]);
                    ex.input("flow1", flow[1][ti]);
                    ex.input("flow2", flow[2][ti]);
                    ex.input("flow3", flow[3][ti]);
                    ex.extract("out0", out_padded[ti]);
                }
                {
                    ncnn::Extractor ex = flownet.create_extractor();

                    ex.input("in0", in1_padded[ti]);
                    ex.input("in1", in0_padded[ti]);
                    ex.input("in2", timestep_padded_reversed[ti / 4]);
                    ex.input("flow0", flow_reversed[0][ti]);
                    ex.input("flow1", flow_reversed[1][ti]);
                    ex.input("flow2", flow_reversed[2][ti]);
                    ex.input("flow3", flow_reversed[3][ti]);
                    ex.extract("out0", out_padded_reversed[ti]);
                }
            }
        }
        else
        {
            ncnn::Mat flow[4][8];
            for (int fi = 0; fi < 4; fi++)
            {
                for (int ti = 0; ti < 8; ti++)
                {
                    // flownet flow mask
                    ncnn::Extractor ex = flownet.create_extractor();

                    ex.input("in0", in0_padded[ti]);
                    ex.input("in1", in1_padded[ti]);
                    ex.input("in2", timestep_padded[ti / 4]);

                    // intentional fall through
                    switch (fi)
                    {
                    case 3: ex.input("flow2", flow[2][ti]);
                    case 2: ex.input("flow1", flow[1][ti]);
                    case 1: ex.input("flow0", flow[0][ti]);
                    default:
                    {
                        char tmp[16];
                        sprintf(tmp, "flow%d", fi);
                        ex.extract(tmp, flow[fi][ti]);
                    }
                    }
                }

                // avg flow mask
                {
                    ncnn::Mat flow_x0 = flow[fi][0].channel(0);
                    ncnn::Mat flow_x1 = flow[fi][1].channel(0);
                    ncnn::Mat flow_x2 = flow[fi][2].channel(0);
                    ncnn::Mat flow_x3 = flow[fi][3].channel(0);
                    ncnn::Mat flow_x4 = flow[fi][4].channel(0);
                    ncnn::Mat flow_x5 = flow[fi][5].channel(0);
                    ncnn::Mat flow_x6 = flow[fi][6].channel(0);
                    ncnn::Mat flow_x7 = flow[fi][7].channel(0);

                    ncnn::Mat flow_y0 = flow[fi][0].channel(1);
                    ncnn::Mat flow_y1 = flow[fi][1].channel(1);
                    ncnn::Mat flow_y2 = flow[fi][2].channel(1);
                    ncnn::Mat flow_y3 = flow[fi][3].channel(1);
                    ncnn::Mat flow_y4 = flow[fi][4].channel(1);
                    ncnn::Mat flow_y5 = flow[fi][5].channel(1);
                    ncnn::Mat flow_y6 = flow[fi][6].channel(1);
                    ncnn::Mat flow_y7 = flow[fi][7].channel(1);

                    ncnn::Mat flow_z0 = flow[fi][0].channel(2);
                    ncnn::Mat flow_z1 = flow[fi][1].channel(2);
                    ncnn::Mat flow_z2 = flow[fi][2].channel(2);
                    ncnn::Mat flow_z3 = flow[fi][3].channel(2);
                    ncnn::Mat flow_z4 = flow[fi][4].channel(2);
                    ncnn::Mat flow_z5 = flow[fi][5].channel(2);
                    ncnn::Mat flow_z6 = flow[fi][6].channel(2);
                    ncnn::Mat flow_z7 = flow[fi][7].channel(2);

                    ncnn::Mat flow_w0 = flow[fi][0].channel(3);
                    ncnn::Mat flow_w1 = flow[fi][1].channel(3);
                    ncnn::Mat flow_w2 = flow[fi][2].channel(3);
                    ncnn::Mat flow_w3 = flow[fi][3].channel(3);
                    ncnn::Mat flow_w4 = flow[fi][4].channel(3);
                    ncnn::Mat flow_w5 = flow[fi][5].channel(3);
                    ncnn::Mat flow_w6 = flow[fi][6].channel(3);
                    ncnn::Mat flow_w7 = flow[fi][7].channel(3);

                    ncnn::Mat flow_m0 = flow[fi][0].channel(4);
                    ncnn::Mat flow_m1 = flow[fi][1].channel(4);
                    ncnn::Mat flow_m2 = flow[fi][2].channel(4);
                    ncnn::Mat flow_m3 = flow[fi][3].channel(4);
                    ncnn::Mat flow_m4 = flow[fi][4].channel(4);
                    ncnn::Mat flow_m5 = flow[fi][5].channel(4);
                    ncnn::Mat flow_m6 = flow[fi][6].channel(4);
                    ncnn::Mat flow_m7 = flow[fi][7].channel(4);

                    for (int i = 0; i < flow_x0.h; i++)
                    {
                        float* x0 = flow_x0.row(i);
                        float* x1 = flow_x1.row(i) + flow_x0.w - 1;
                        float* x2 = flow_x2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                        float* x3 = flow_x3.row(flow_x0.h - 1 - i);

                        float* y0 = flow_y0.row(i);
                        float* y1 = flow_y1.row(i) + flow_x0.w - 1;
                        float* y2 = flow_y2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                        float* y3 = flow_y3.row(flow_x0.h - 1 - i);

                        float* z0 = flow_z0.row(i);
                        float* z1 = flow_z1.row(i) + flow_x0.w - 1;
                        float* z2 = flow_z2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                        float* z3 = flow_z3.row(flow_x0.h - 1 - i);

                        float* w0 = flow_w0.row(i);
                        float* w1 = flow_w1.row(i) + flow_x0.w - 1;
                        float* w2 = flow_w2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                        float* w3 = flow_w3.row(flow_x0.h - 1 - i);

                        float* m0 = flow_m0.row(i);
                        float* m1 = flow_m1.row(i) + flow_x0.w - 1;
                        float* m2 = flow_m2.row(flow_x0.h - 1 - i) + flow_x0.w - 1;
                        float* m3 = flow_m3.row(flow_x0.h - 1 - i);

                        for (int j = 0; j < flow_x0.w; j++)
                        {
                            float* x4 = flow_x4.row(j) + i;
                            float* x5 = flow_x5.row(j) + flow_x0.h - 1 - i;
                            float* x6 = flow_x6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                            float* x7 = flow_x7.row(flow_x0.w - 1 - j) + i;

                            float* y4 = flow_y4.row(j) + i;
                            float* y5 = flow_y5.row(j) + flow_x0.h - 1 - i;
                            float* y6 = flow_y6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                            float* y7 = flow_y7.row(flow_x0.w - 1 - j) + i;

                            float* z4 = flow_z4.row(j) + i;
                            float* z5 = flow_z5.row(j) + flow_x0.h - 1 - i;
                            float* z6 = flow_z6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                            float* z7 = flow_z7.row(flow_x0.w - 1 - j) + i;

                            float* w4 = flow_w4.row(j) + i;
                            float* w5 = flow_w5.row(j) + flow_x0.h - 1 - i;
                            float* w6 = flow_w6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                            float* w7 = flow_w7.row(flow_x0.w - 1 - j) + i;

                            float* m4 = flow_m4.row(j) + i;
                            float* m5 = flow_m5.row(j) + flow_x0.h - 1 - i;
                            float* m6 = flow_m6.row(flow_x0.w - 1 - j) + flow_x0.h - 1 - i;
                            float* m7 = flow_m7.row(flow_x0.w - 1 - j) + i;

                            float x = (*x0 + -*x1 + -*x2 + *x3 + *y4 + *y5 + -*y6 + -*y7) * 0.125f;
                            float y = (*y0 + *y1 + -*y2 + -*y3 + *x4 + -*x5 + -*x6 + *x7) * 0.125f;
                            float z = (*z0 + -*z1 + -*z2 + *z3 + *w4 + *w5 + -*w6 + -*w7) * 0.125f;
                            float w = (*w0 + *w1 + -*w2 + -*w3 + *z4 + -*z5 + -*z6 + *z7) * 0.125f;
                            float m = (*m0 + *m1 + *m2 + *m3 + *m4 + *m5 + *m6 + *m7) * 0.125f;

                            *x0++ = x;
                            *x1-- = -x;
                            *x2-- = -x;
                            *x3++ = x;
                            *x4 = y;
                            *x5 = -y;
                            *x6 = -y;
                            *x7 = y;

                            *y0++ = y;
                            *y1-- = y;
                            *y2-- = -y;
                            *y3++ = -y;
                            *y4 = x;
                            *y5 = x;
                            *y6 = -x;
                            *y7 = -x;

                            *z0++ = z;
                            *z1-- = -z;
                            *z2-- = -z;
                            *z3++ = z;
                            *z4 = w;
                            *z5 = -w;
                            *z6 = -w;
                            *z7 = w;

                            *w0++ = w;
                            *w1-- = w;
                            *w2-- = -w;
                            *w3++ = -w;
                            *w4 = z;
                            *w5 = z;
                            *w6 = -z;
                            *w7 = -z;

                            *m0++ = m;
                            *m1-- = m;
                            *m2-- = m;
                            *m3++ = m;
                            *m4 = m;
                            *m5 = m;
                            *m6 = m;
                            *m7 = m;
                        }
                    }
                }
            }

            for (int ti = 0; ti < 8; ti++)
            {
                // flownet
                {
                    ncnn::Extractor ex = flownet.create_extractor();

                    ex.input("in0", in0_padded[ti]);
                    ex.input("in1", in1_padded[ti]);
                    ex.input("in2", timestep_padded[ti / 4]);
                    ex.input("flow0", flow[0][ti]);
                    ex.input("flow1", flow[1][ti]);
                    ex.input("flow2", flow[2][ti]);
                    ex.input("flow3", flow[3][ti]);
                    ex.extract("out0", out_padded[ti]);
                }
            }
        }

        // cut padding and postproc
        out.create(w, h, 3);
        if (tta_temporal_mode)
        {
            for (int q = 0; q < 3; q++)
            {
                const ncnn::Mat out_padded_0 = out_padded[0].channel(q);
                const ncnn::Mat out_padded_1 = out_padded[1].channel(q);
                const ncnn::Mat out_padded_2 = out_padded[2].channel(q);
                const ncnn::Mat out_padded_3 = out_padded[3].channel(q);
                const ncnn::Mat out_padded_4 = out_padded[4].channel(q);
                const ncnn::Mat out_padded_5 = out_padded[5].channel(q);
                const ncnn::Mat out_padded_6 = out_padded[6].channel(q);
                const ncnn::Mat out_padded_7 = out_padded[7].channel(q);
                const ncnn::Mat out_padded_reversed_0 = out_padded_reversed[0].channel(q);
                const ncnn::Mat out_padded_reversed_1 = out_padded_reversed[1].channel(q);
                const ncnn::Mat out_padded_reversed_2 = out_padded_reversed[2].channel(q);
                const ncnn::Mat out_padded_reversed_3 = out_padded_reversed[3].channel(q);
                const ncnn::Mat out_padded_reversed_4 = out_padded_reversed[4].channel(q);
                const ncnn::Mat out_padded_reversed_5 = out_padded_reversed[5].channel(q);
                const ncnn::Mat out_padded_reversed_6 = out_padded_reversed[6].channel(q);
                const ncnn::Mat out_padded_reversed_7 = out_padded_reversed[7].channel(q);
                float* outptr = out.channel(q);

                for (int i = 0; i < h; i++)
                {
                    const float* ptr0 = out_padded_0.row(i);
                    const float* ptr1 = out_padded_1.row(i) + w_padded - 1;
                    const float* ptr2 = out_padded_2.row(h_padded - 1 - i) + w_padded - 1;
                    const float* ptr3 = out_padded_3.row(h_padded - 1 - i);
                    const float* ptrr0 = out_padded_reversed_0.row(i);
                    const float* ptrr1 = out_padded_reversed_1.row(i) + w_padded - 1;
                    const float* ptrr2 = out_padded_reversed_2.row(h_padded - 1 - i) + w_padded - 1;
                    const float* ptrr3 = out_padded_reversed_3.row(h_padded - 1 - i);

                    for (int j = 0; j < w; j++)
                    {
                        const float* ptr4 = out_padded_4.row(j) + i;
                        const float* ptr5 = out_padded_5.row(j) + h_padded - 1 - i;
                        const float* ptr6 = out_padded_6.row(w_padded - 1 - j) + h_padded - 1 - i;
                        const float* ptr7 = out_padded_7.row(w_padded - 1 - j) + i;
                        const float* ptrr4 = out_padded_reversed_4.row(j) + i;
                        const float* ptrr5 = out_padded_reversed_5.row(j) + h_padded - 1 - i;
                        const float* ptrr6 = out_padded_reversed_6.row(w_padded - 1 - j) + h_padded - 1 - i;
                        const float* ptrr7 = out_padded_reversed_7.row(w_padded - 1 - j) + i;

                        float v = (*ptr0++ + *ptr1-- + *ptr2-- + *ptr3++ + *ptr4 + *ptr5 + *ptr6 + *ptr7) / 8;
                        float vr = (*ptrr0++ + *ptrr1-- + *ptrr2-- + *ptrr3++ + *ptrr4 + *ptrr5 + *ptrr6 + *ptrr7) / 8;

                        *outptr++ = (v + vr) * 0.5f * 255.f + 0.5f;
                    }
                }
            }
        }
        else
        {
            for (int q = 0; q < 3; q++)
            {
                const ncnn::Mat out_padded_0 = out_padded[0].channel(q);
                const ncnn::Mat out_padded_1 = out_padded[1].channel(q);
                const ncnn::Mat out_padded_2 = out_padded[2].channel(q);
                const ncnn::Mat out_padded_3 = out_padded[3].channel(q);
                const ncnn::Mat out_padded_4 = out_padded[4].channel(q);
                const ncnn::Mat out_padded_5 = out_padded[5].channel(q);
                const ncnn::Mat out_padded_6 = out_padded[6].channel(q);
                const ncnn::Mat out_padded_7 = out_padded[7].channel(q);
                float* outptr = out.channel(q);

                for (int i = 0; i < h; i++)
                {
                    const float* ptr0 = out_padded_0.row(i);
                    const float* ptr1 = out_padded_1.row(i) + w_padded - 1;
                    const float* ptr2 = out_padded_2.row(h_padded - 1 - i) + w_padded - 1;
                    const float* ptr3 = out_padded_3.row(h_padded - 1 - i);

                    for (int j = 0; j < w; j++)
                    {
                        const float* ptr4 = out_padded_4.row(j) + i;
                        const float* ptr5 = out_padded_5.row(j) + h_padded - 1 - i;
                        const float* ptr6 = out_padded_6.row(w_padded - 1 - j) + h_padded - 1 - i;
                        const float* ptr7 = out_padded_7.row(w_padded - 1 - j) + i;

                        float v = (*ptr0++ + *ptr1-- + *ptr2-- + *ptr3++ + *ptr4 + *ptr5 + *ptr6 + *ptr7) / 8;

                        *outptr++ = v * 255.f + 0.5f;
                    }
                }
            }
        }
    }
    else
    {
        // preproc and border padding
        ncnn::Mat in0_padded;
        ncnn::Mat in1_padded;
        ncnn::Mat timestep_padded;
        {
            in0_padded.create(w_padded, h_padded, 3);
            for (int q = 0; q < 3; q++)
            {
                float* outptr = in0_padded.channel(q);

                int i = 0;
                for (; i < h; i++)
                {
                    const float* ptr = in0.channel(q).row(i);

                    int j = 0;
                    for (; j < w; j++)
                    {
                        *outptr++ = *ptr++ * (1 / 255.f);
                    }
                    for (; j < w_padded; j++)
                    {
                        *outptr++ = 0.f;
                    }
                }
                for (; i < h_padded; i++)
                {
                    for (int j = 0; j < w_padded; j++)
                    {
                        *outptr++ = 0.f;
                    }
                }
            }
        }
        {
            in1_padded.create(w_padded, h_padded, 3);
            for (int q = 0; q < 3; q++)
            {
                float* outptr = in1_padded.channel(q);

                int i = 0;
                for (; i < h; i++)
                {
                    const float* ptr = in1.channel(q).row(i);

                    int j = 0;
                    for (; j < w; j++)
                    {
                        *outptr++ = *ptr++ * (1 / 255.f);
                    }
                    for (; j < w_padded; j++)
                    {
                        *outptr++ = 0.f;
                    }
                }
                for (; i < h_padded; i++)
                {
                    for (int j = 0; j < w_padded; j++)
                    {
                        *outptr++ = 0.f;
                    }
                }
            }
        }
        {
            timestep_padded.create(w_padded, h_padded, 1);
            timestep_padded.fill(timestep);
        }

        ncnn::Mat out_padded;
        ncnn::Mat out_padded_reversed;
        if (tta_temporal_mode)
        {
            ncnn::Mat timestep_padded_reversed;
            {
                timestep_padded_reversed.create(w_padded, h_padded, 1);
                timestep_padded_reversed.fill(1.f - timestep);
            }

            ncnn::Mat flow[4];
            ncnn::Mat flow_reversed[4];
            for (int fi = 0; fi < 4; fi++)
            {
                {
                    // flownet flow mask
                    ncnn::Extractor ex = flownet.create_extractor();

                    ex.input("in0", in0_padded);
                    ex.input("in1", in1_padded);
                    ex.input("in2", timestep_padded);

                    // intentional fall through
                    switch (fi)
                    {
                    case 3: ex.input("flow2", flow[2]);
                    case 2: ex.input("flow1", flow[1]);
                    case 1: ex.input("flow0", flow[0]);
                    default:
                    {
                        char tmp[16];
                        sprintf(tmp, "flow%d", fi);
                        ex.extract(tmp, flow[fi]);
                    }
                    }
                }

                {
                    // flownet flow mask reversed
                    ncnn::Extractor ex = flownet.create_extractor();

                    ex.input("in0", in1_padded);
                    ex.input("in1", in0_padded);
                    ex.input("in2", timestep_padded_reversed);

                    // intentional fall through
                    switch (fi)
                    {
                    case 3: ex.input("flow2", flow_reversed[2]);
                    case 2: ex.input("flow1", flow_reversed[1]);
                    case 1: ex.input("flow0", flow_reversed[0]);
                    default:
                    {
                        char tmp[16];
                        sprintf(tmp, "flow%d", fi);
                        ex.extract(tmp, flow_reversed[fi]);
                    }
                    }
                }

                // merge flow and flow_reversed
                {
                    float* flow_x = flow[fi].channel(0);
                    float* flow_y = flow[fi].channel(1);
                    float* flow_z = flow[fi].channel(2);
                    float* flow_w = flow[fi].channel(3);
                    float* flow_m = flow[fi].channel(4);
                    float* flow_reversed_x = flow_reversed[fi].channel(0);
                    float* flow_reversed_y = flow_reversed[fi].channel(1);
                    float* flow_reversed_z = flow_reversed[fi].channel(2);
                    float* flow_reversed_w = flow_reversed[fi].channel(3);
                    float* flow_reversed_m = flow_reversed[fi].channel(4);

                    for (int i = 0; i < flow[fi].h; i++)
                    {
                        for (int j = 0; j < flow[fi].w; j++)
                        {
                            float x = (*flow_x + *flow_reversed_z) * 0.5f;
                            float y = (*flow_y + *flow_reversed_w) * 0.5f;
                            float z = (*flow_z + *flow_reversed_x) * 0.5f;
                            float w = (*flow_w + *flow_reversed_y) * 0.5f;
                            float m = (*flow_m - *flow_reversed_m) * 0.5f;

                            *flow_x++ = x;
                            *flow_y++ = y;
                            *flow_z++ = z;
                            *flow_w++ = w;
                            *flow_m++ = m;
                            *flow_reversed_x++ = z;
                            *flow_reversed_y++ = w;
                            *flow_reversed_z++ = x;
                            *flow_reversed_w++ = y;
                            *flow_reversed_m++ = -m;
                        }
                    }
                }
            }

            {
                // flownet
                ncnn::Extractor ex = flownet.create_extractor();

                ex.input("in0", in0_padded);
                ex.input("in1", in1_padded);
                ex.input("in2", timestep_padded);
                ex.input("flow0", flow[0]);
                ex.input("flow1", flow[1]);
                ex.input("flow2", flow[2]);
                ex.input("flow3", flow[3]);

                ex.extract("out0", out_padded);
            }
            {
                ncnn::Extractor ex = flownet.create_extractor();

                ex.input("in0", in1_padded);
                ex.input("in1", in0_padded);
                ex.input("in2", timestep_padded_reversed);
                ex.input("flow0", flow_reversed[0]);
                ex.input("flow1", flow_reversed[1]);
                ex.input("flow2", flow_reversed[2]);
                ex.input("flow3", flow_reversed[3]);

                ex.extract("out0", out_padded_reversed);
            }
        }
        else
        {
            // flownet
            ncnn::Extractor ex = flownet.create_extractor();

            ex.input("in0", in0_padded);
            ex.input("in1", in1_padded);
            ex.input("in2", timestep_padded);
            ex.extract("out0", out_padded);
        }

        // cut padding and postproc
        out.create(w, h, 3);
        if (tta_temporal_mode)
        {
            for (int q = 0; q < 3; q++)
            {
                float* outptr = out.channel(q);
                const float* ptr = out_padded.channel(q);
                const float* ptr1 = out_padded_reversed.channel(q);

                for (int i = 0; i < h; i++)
                {
                    for (int j = 0; j < w; j++)
                    {
                        *outptr++ = (*ptr++ + *ptr1++) * 0.5f * 255.f + 0.5f;
                    }
                }
            }
        }
        else
        {
            for (int q = 0; q < 3; q++)
            {
                float* outptr = out.channel(q);
                const float* ptr = out_padded.channel(q);

                for (int i = 0; i < h; i++)
                {
                    for (int j = 0; j < w; j++)
                    {
                        *outptr++ = *ptr++ * 255.f + 0.5f;
                    }
                }
            }
        }
    }

    // download
    {
#if _WIN32
        out.to_pixels((unsigned char*)outimage.data, ncnn::Mat::PIXEL_RGB2BGR);
#else
        out.to_pixels((unsigned char*)outimage.data, ncnn::Mat::PIXEL_RGB);
#endif
    }

    return 0;
}
