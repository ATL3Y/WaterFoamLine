using System;
using UnityEngine;
using UnityEngine.Rendering;
using Object = UnityEngine.Object;
using RenderSettings = PlaceholderSoftware.WetStuff.Rendering.RenderSettings;

namespace PlaceholderSoftware.WetStuff
{
    /// <summary>
    ///     Modifies the GBuffer textures to simulate wet surfaces.
    /// </summary>
    internal class WetAttributeModifier : IDisposable
    {
        private readonly Camera _camera;
        private readonly Material _material;

        public float AmbientDarkenStrength
        {
            get { return _material.GetFloat("_AmbientDarken"); }
            set { _material.SetFloat("_AmbientDarken", value); }
        }

        public WetAttributeModifier([NotNull] Camera camera)
        {
            if (!camera) throw new ArgumentNullException("camera");

            _material = new Material(Shader.Find("Hidden/WetSurfaceModifier")) {
                hideFlags = HideFlags.DontSave
            };

            _camera = camera;
        }

        public void Dispose()
        {
            Object.DestroyImmediate(_material);
        }

        public void RecordCommandBuffer([NotNull] CommandBuffer cmd)
        {
            var fsq = Primitives.CreateFullscreenQuad();

            // Copy the specular texture, as we need to both read and write to it
            var specularId = CopyGBufferTexture(cmd, "_GBufferSpecularCopy", BuiltinRenderTextureType.GBuffer1, _camera.allowHDR);

            // Render our effect into the diffuse and specular gbuffer targets as a full screen pass
            cmd.SetRenderTarget(
                new RenderTargetIdentifier[] { BuiltinRenderTextureType.GBuffer0, BuiltinRenderTextureType.GBuffer1, BuiltinRenderTextureType.CameraTarget },
                BuiltinRenderTextureType.CameraTarget
            );

            cmd.DrawMesh(fsq, Matrix4x4.identity, _material, 0, RenderSettings.Instance.EnableStencil ? 1 : 0);

            // Release our copy of the specular texture
            cmd.ReleaseTemporaryRT(specularId);
        }

        private static int CopyGBufferTexture([NotNull] CommandBuffer cmd, [NotNull] string shaderParameterName, BuiltinRenderTextureType texture, bool hdr)
        {
            if (cmd == null) throw new ArgumentNullException("cmd");

            var id = Shader.PropertyToID(shaderParameterName);

            cmd.GetTemporaryRT(id, -1, -1, 0, FilterMode.Point, GBufferFormat(texture, hdr));
            cmd.Blit(texture, id);

            return id;
        }

        private static RenderTextureFormat GBufferFormat(BuiltinRenderTextureType gbuffer, bool hdr)
        {
            // https://docs.unity3d.com/Manual/RenderTech-DeferredShading.html

            switch (gbuffer)
            {
                // RT0, ARGB32 format: Diffuse color (RGB), occlusion(A).
                case BuiltinRenderTextureType.GBuffer0:
                    return RenderTextureFormat.ARGB32;

                // RT1, ARGB32 format: Specular color (RGB), roughness (A).
                case BuiltinRenderTextureType.GBuffer1:
                    return RenderTextureFormat.ARGB32;

                // RT2, ARGB2101010 format: World space normal (RGB), unused (A).
                case BuiltinRenderTextureType.GBuffer2:
                    return RenderTextureFormat.ARGB2101010;

                // RT3, Light Buffer
                case BuiltinRenderTextureType.GBuffer3:
                    return hdr ? RenderTextureFormat.ARGBHalf : RenderTextureFormat.ARGB2101010;

                default:
                    throw new ArgumentException("Provided render texture type is not a GBuffer", "gbuffer");
            }
        }
    }
}