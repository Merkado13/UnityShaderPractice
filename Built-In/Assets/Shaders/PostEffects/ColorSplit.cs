using System;
using UnityEngine;

[ImageEffectAllowedInSceneView, ExecuteInEditMode]
public class ColorSplit : MonoBehaviour
{

    public Vector2 redOffset;
    public Vector2 greenOffset;
    public Vector2 blueOffset;

    private Camera cam;
    private Shader shader;
    private Material material;

    private void OnPreCull()
    {
        if (cam == null) cam = GetComponent<Camera>();
        if(shader == null) shader = Shader.Find("Custom/Effects/ColorSplit");
        if(shader != null && material == null) material = new Material(shader);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!cam || !material)
        {
            Graphics.Blit(src, dest);
        }
        else
        {
            material.SetVector("_ROffset", redOffset);
            material.SetVector("_GOffset", greenOffset);
            material.SetVector("_BOffset", blueOffset);
            Graphics.Blit(src, dest, material);
        }
    }

    private void OnDisable()
    {
#if UNITY_EDITOR
        if(Application.isPlaying) Destroy(material);
        else DestroyImmediate(material);
#else
        Destroy(material)
#endif
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
