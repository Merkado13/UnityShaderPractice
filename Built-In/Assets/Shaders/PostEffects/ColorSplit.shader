Shader "Custom/Effects/ColorSplit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ROffset("Red offset", Vector) = (0,0,0,0)
        _GOffset("Green offset", Vector) = (0,0,0,0)
        _BOffset("Blue offset", Vector) = (0,0,0,0)
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float2 _ROffset, _GOffset, _BOffset;
            
            fixed4 frag (v2f i) : SV_Target
            {
                half red = tex2D(_MainTex, i.uv + _ROffset).r;
                half green = tex2D(_MainTex, i.uv + _GOffset).g;
                half blue = tex2D(_MainTex, i.uv + _BOffset).b;
                return half4(red, green, blue, 1);
            }
            ENDCG
        }
    }
}
