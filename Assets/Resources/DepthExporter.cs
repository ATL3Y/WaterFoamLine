using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess ( typeof ( DepthExporterRenderer ), PostProcessEvent.BeforeStack, "Custom/DepthExport" )]
//[PostProcess ( typeof ( DepthExporterRenderer ), PostProcessEvent.AfterStack, "Custom/DepthExport" )]
public sealed class DepthExporter : PostProcessEffectSettings
{
    //public RenderTextureParameter depthTexture;

}

public sealed class DepthExporterRenderer : PostProcessEffectRenderer<DepthExporter>
{
    public override DepthTextureMode GetCameraFlags ( )
    {
        return DepthTextureMode.Depth;
    }

    public override void Render ( PostProcessRenderContext context )
    {
        Debug.Log ( "running" );
        var sheet = context.propertySheets.Get(Shader.Find("Custom/DepthShader"));
        //sheet.properties.SetFloat("_Blend", settings.blend);
        context.command.BlitFullscreenTriangle ( context.source, context.destination, sheet, 0 );
    }
}

[Serializable]
public sealed class RenderTextureParameter : ParameterOverride<RenderTexture> { }
