Shader "Custom/Color Skybox with Gradient" {
Properties {
    _SkyTint ("Sky", Color) = (.5, .5, .5, 1)
    
    _Gradient ("Gradient", 2D) = "white" {}

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

        uniform half4 _SkyTint;
        uniform half _HorizonSize;
        sampler2D _Gradient;


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
            half pos = 0;
            if (IN.skyGroundFactor<0){
                pos = lerp(0.5,0,saturate((1-IN.skyGroundFactor-1)/_HorizonSize));
            } else {
                pos = lerp(0.5,1,saturate((IN.skyGroundFactor)/_HorizonSize));
            }       
            return tex2D (_Gradient, half2(pos,0) )*_SkyTint;
        }

        ENDCG
    }
}


Fallback Off

}