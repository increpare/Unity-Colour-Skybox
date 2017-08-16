// MIT license (see license.txt)

Shader "Custom/Color Skybox" {
Properties {
    _SkyTint ("Sky", Color) = (.5, .5, .5, 1)
    _HorizonColor ("Horizon", Color) = (1.0, 1.0, 1.0, 1)
    _GroundColor ("Ground", Color) = (.369, .349, .341, 1)
    _HorizonSize("Horizon Size", Range(0.00001,1)) = 1.0
}

SubShader {
    Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
    Cull Off ZWrite Off

    Pass {

        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        #include "UnityCG.cginc"
        #include "Lighting.cginc"

        uniform half3 _SkyTint;
        uniform half3 _HorizonColor;
        uniform half3 _GroundColor;
        uniform half _HorizonSize;

        struct appdata_t
        {
            float4 vertex : POSITION;
        };

        struct v2f
        {
            float4  pos             : SV_POSITION;
            half    skyGroundFactor : TEXCOORD0;            
        };


        v2f vert (appdata_t v)
        {
            v2f OUT;
            OUT.pos = UnityObjectToClipPos(v.vertex);
            float3 eyeRay = normalize(mul((float3x3)unity_ObjectToWorld, v.vertex.xyz));
            OUT.skyGroundFactor = sign(eyeRay.y)*pow( abs(eyeRay.y) , _HorizonSize);
            return OUT;
        }


        half4 frag (v2f IN) : SV_Target
        {
            half3 col = half3(0.0, 0.0, 0.0);
            if (IN.skyGroundFactor<0){
                col=lerp(_HorizonColor,_GroundColor,saturate((1-IN.skyGroundFactor-1)/_HorizonSize));
            } else {
                col=lerp(_HorizonColor,_SkyTint,saturate((IN.skyGroundFactor)/_HorizonSize));
            }       
            return half4(col,1.0);
        }
        ENDCG
    }
}


Fallback Off

}
