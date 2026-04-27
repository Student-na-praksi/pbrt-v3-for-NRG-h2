// simplepath.h - Minimal teaching path integrator
#ifndef PBRT_MYCORE_SIMPLEPATH_H
#define PBRT_MYCORE_SIMPLEPATH_H

#include "../core/integrator.h"

namespace pbrt {

class SimplePathIntegrator : public SamplerIntegrator {
  public:
    SimplePathIntegrator(int maxDepth, std::shared_ptr<const Camera> camera,
                        std::shared_ptr<Sampler> sampler,
                        const Bounds2i &pixelBounds);
    void Preprocess(const Scene &scene, Sampler &sampler) {}
    Spectrum Li(const RayDifferential &r, const Scene &scene, Sampler &sampler,
                MemoryArena &arena, int depth) const;
  private:
    const int maxDepth;
};

SimplePathIntegrator *CreateSimplePathIntegrator(const ParamSet &params,
                                               std::shared_ptr<Sampler> sampler,
                                               std::shared_ptr<const Camera> camera);

}  // namespace pbrt

#endif
