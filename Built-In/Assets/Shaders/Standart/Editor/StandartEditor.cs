using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class StandardEditor : UtilShaderGUI
{
    #region Keyword Enums
    protected enum SmoothSource
    {
        None,
        MetallicAlpha,
        AlbedoAlpha,
        FirstMapRedChannel,
        SecondMapRedChannel
    }
    protected Dictionary<SmoothSource, string> smoothKeywords = new Dictionary<SmoothSource, string>()
    {
        { SmoothSource.MetallicAlpha, "_SMOOTH_FIRSTA" },
        { SmoothSource.AlbedoAlpha, "_SMOOTH_ALBEDOA" },
        { SmoothSource.FirstMapRedChannel, "_SMOOTH_FIRSTR" },
        { SmoothSource.SecondMapRedChannel, "_SMOOTH_SECONDR" },
    };

    protected enum MetalSource
    {
        None,
        RedChannel,
        GreenChannel
    }
    protected Dictionary<MetalSource, string> metalKeywords = new Dictionary<MetalSource, string>()
    {
        { MetalSource.None, "_METAL_NONE" },
        { MetalSource.RedChannel, "_METAL_FIRSTR" },
        { MetalSource.GreenChannel, "_METAL_FIRSTG" }
    };
    protected enum OcclusionSource
    {
        None,
        OcclusionMap,
        FirstMapBlueChannel,
        FirstMapGreenChannel,
        AlbedoAlpha
    }
    protected Dictionary<OcclusionSource, string> aoKeywords = new Dictionary<OcclusionSource, string>()
    {
        { OcclusionSource.None, "_AO_NONE" },
        { OcclusionSource.OcclusionMap, "_AO_AO" },
        { OcclusionSource.FirstMapBlueChannel, "_AO_FIRSTB" },
        { OcclusionSource.FirstMapGreenChannel, "_AO_FIRSTG" },
        { OcclusionSource.AlbedoAlpha, "_AO_ALBEDOA" },
    };
    #endregion

    protected override void Update()
    {
        if (IsVisible("_ShowMainMaps")) MainMaps();
        if (IsVisible("_ShowRim")) Rim();
        if (IsVisible("_ShowShiny")) ShinyMaps();
    }

    #region Editor
    void MainMaps()
    {
        GUILayout.Label("Main Maps", EditorStyles.boldLabel);
        SingleLineTexture("_MainTex", "_Color", true);
        SingleLineTexture("_BumpMap", "_NormalStrength", tooltip: "put normal map here");
        SingleLineTexture("_EmissionMap", "_EmissionColor");
        EditorGUILayout.Space();
    }

    void Rim()
    {
        GUILayout.Label("Fresnel Rim", EditorStyles.boldLabel);
        Property("_RimColor");
        Property("_RimPower");
        Property("_RimSmooth");
        EditorGUILayout.Space();
    }

    void ShinyMaps()
    {
        GUILayout.Label("Shiny Maps", EditorStyles.boldLabel);
        SmoothSource smoothSource = GetKeyword(smoothKeywords);
        MetalSource metalSource = GetKeyword(metalKeywords);
        OcclusionSource aoSource = GetKeyword(aoKeywords);

        bool useFirstMap = metalSource != MetalSource.None ||
            smoothSource == SmoothSource.FirstMapRedChannel || smoothSource == SmoothSource.MetallicAlpha ||
            aoSource == OcclusionSource.FirstMapBlueChannel || aoSource == OcclusionSource.FirstMapGreenChannel;
        bool useSecondMap = smoothSource == SmoothSource.SecondMapRedChannel;
        bool useAOMap = aoSource == OcclusionSource.OcclusionMap;
        int indent = useFirstMap || useSecondMap || useAOMap ? 2 : 0;

        if (useFirstMap) SingleLineTexture("_MetallicGlossMap", "_Metallic", displayName: "Metallic");
        if (useSecondMap) SingleLineTexture("_SpecGlossMap", "_Glossiness");
        if (!useFirstMap) Property("_Metallic", labelIndent: indent);
        if (!useSecondMap) Property("_Glossiness", labelIndent: indent);
        if (useAOMap) SingleLineTexture("_OcclusionMap", "_OcclusionStrength");
        else Property("_OcclusionStrength", labelIndent: indent);

        EditorGUILayout.Space();

        KeywordDropdown(smoothKeywords, smoothSource, "Smoothness Source", 
            "Select none for smoothness to be controlled entirely by slider");
        KeywordDropdown(metalKeywords, metalSource, "Metallic Source", 
            "Select none for metallic to be controlled entirely by slider");
        KeywordDropdown(aoKeywords, aoSource, "OcclusionSource");
        KeywordToggle("_ROUGHNESS_ON", "Using roughness?");
    }
    #endregion
}