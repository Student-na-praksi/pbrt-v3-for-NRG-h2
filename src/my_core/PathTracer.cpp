#include "simplepath.h"
#include "../core/camera.h"
#include "../core/interaction.h"
#include "../core/paramset.h"
#include "../core/scene.h"

namespace pbrt {

SimplePathIntegrator::SimplePathIntegrator(int maxDepth,
                                           std::shared_ptr<const Camera> camera,
                                           std::shared_ptr<Sampler> sampler,
                                           const Bounds2i &pixelBounds)
    : SamplerIntegrator(camera, sampler, pixelBounds), maxDepth(maxDepth) {}

Spectrum SimplePathIntegrator::Li(const RayDifferential &r, const Scene &scene,
                                 Sampler &sampler, MemoryArena &arena,
                                 int depth) const {
    Spectrum L(0.f), beta(1.f);
    RayDifferential ray(r);
    bool specularBounce = false;

    for (int bounces = 0; bounces < maxDepth; ++bounces) {
        SurfaceInteraction isect;
        bool found = scene.Intersect(ray, &isect);
        if (bounces == 0 || specularBounce) {
            if (found) {
                L += beta * isect.Le(-ray.d);
            } else {
                for (const auto &light : scene.infiniteLights)
                    L += beta * light->Le(ray);
            }
        }

        if (!found) break;

        // Compute scattering functions
        isect.ComputeScatteringFunctions(ray, arena, true);
        if (!isect.bsdf) {
            ray = isect.SpawnRay(ray.d);
            continue;
        }

        // Sample a light directly at the current surface point.
        if (isect.bsdf->NumComponents(BxDFType(BSDF_ALL & ~BSDF_SPECULAR)) > 0)
            L += beta * UniformSampleOneLight(isect, scene, arena, sampler, false);

        // Sample BSDF for next direction (importance sampling)
        Vector3f wo = -ray.d, wi;
        Float pdf;
        BxDFType flags;
        Spectrum f = isect.bsdf->Sample_f(wo, &wi, sampler.Get2D(), &pdf, BSDF_ALL, &flags);
        if (f.IsBlack() || pdf == 0.f) break;

        beta *= f * AbsDot(wi, isect.shading.n) / pdf;
        ray = isect.SpawnRay(wi);
        specularBounce = (flags & BSDF_SPECULAR) != 0;

        // Russian roulette termination after a few bounces
        if (bounces > 3) {
            Float q = std::max((Float)0.05, 1 - beta.MaxComponentValue());
            if (sampler.Get1D() < q) break;
            beta /= 1 - q;
        }
    }
    return L;
}

SimplePathIntegrator *CreateSimplePathIntegrator(const ParamSet &params,
                                                std::shared_ptr<Sampler> sampler,
                                                std::shared_ptr<const Camera> camera) {
    int maxDepth = params.FindOneInt("maxdepth", 5);
    int np;
    const int *pb = params.FindInt("pixelbounds", &np);
    Bounds2i pixelBounds = camera->film->GetSampleBounds();
    if (pb) {
        if (np == 4)
            pixelBounds = Intersect(pixelBounds, Bounds2i{{pb[0], pb[2]}, {pb[1], pb[3]}});
    }
    return new SimplePathIntegrator(maxDepth, camera, sampler, pixelBounds);
}

}  // namespace pbrt
