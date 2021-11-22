Shader "Custom/Unlit/SpriteColorMask"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        [NoScaleOffset] _Mask("Color Mask", 2D) = "transparent" {}
        _R("Red Channel Color", Color) = (1,1,1,1)
        _G("Green Channel Color", Color) = (1,1,1,1)
        _B("Blue Channel Color", Color) = (1,1,1,1)
        _A("Alpha Color", Color) = (1,1,1,1)
        [Enum(Off, 0, Front, 1, Back, 2)] _Cull("Cull", float) = 2
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent"
            "IgnoreProjector" = "True"
            "Queue" = "Transparent"
            "PreviewType" = "Plane"
            "CanUseSpriteAltas" = "True"
        }

        Cull[_Cull]
        Blend SrcAlpha OneMinusSrcAlpha
        ZTest Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                half4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            sampler2D _Mask;
            float4 _Mask_ST;
            half4 _R;
            half4 _G;
            half4 _B;
            half4 _A;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                half4 mask = tex2D(_Mask, i.uv);
                half4 mix = half4(0, 0, 0, 1);
                mix = lerp(mix, _R, mask.r);
                mix = lerp(mix, _G, mask.g);
                mix = lerp(mix, _B, mask.b);
                mix = lerp(mix, _A, 1 - mask.a);
                return col * mix;
            }
            ENDCG
        }
    }
}
