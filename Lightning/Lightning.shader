Shader "Custom/Lightning"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_MaxDisplacementTex("Max Displacement Texture", 2D) = "white" {}
		_TimeOffset("Time Offset", Range(0,1)) = 0.0
	}

	SubShader
	{
		Tags { "RenderType"="Transparent" }

		Pass
		{
			ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			// Properties
			sampler2D _MainTex;
			float4 _Color;
			sampler2D _NoiseTex;
			sampler2D _MaxDisplacementTex;
			float4 _UVOffset;
			float _TimeOffset;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 texCoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float3 texCoord : TEXCOORD0;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				// convert input to world space
				output.pos = UnityObjectToClipPos(input.vertex);
				// texture coordinates 
				output.texCoord = input.texCoord;
				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				// base color
				float4 col = float4(_Color.rgba);
                // select one different horizontal line from the noise 
			    float noiseLine = tex2Dlod(_NoiseTex, float4( input.texCoord.x, _TimeOffset+_Time.x, 0, 0));
			    // this value means how much the noise can distort the main texture
			    float maxDisplacement = tex2Dlod(_MaxDisplacementTex, float4( input.texCoord.x, input.texCoord.y, 0, 0));
			    // use the noiseLine moderated by the maxDisplacement value to distort the main texture
				float4 albedo = tex2D(_MainTex, float4(input.texCoord.x, input.texCoord.y + (noiseLine - 0.5) * maxDisplacement, 0, 0));
				// this is needed only if you need transparency and your main texture is b/w
				col.a *= albedo.r;
				
				return col;
			}

			ENDCG
		}
	}
}