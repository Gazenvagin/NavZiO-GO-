// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASESampleShaders/VertexNormalReconstruction"
{
    Properties
    {
		_Amplitude("Amplitude", Range( 0 , 10)) = 0
		_Frequency("Frequency", Float) = 0
		_Normalpositiondeviation("Normal position deviation", Range( 0.01 , 1)) = 0.1
		_Flagalbedo("Flag albedo", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
    }

    SubShader
    {
        Tags { "RenderPipeline"="LightweightPipeline" "RenderType"="Opaque" "Queue"="Geometry" }

		Cull Back
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL
		
        Pass
        {
			
        	Tags { "LightMode"="LightweightForward" }

        	Name "VertexNormalReconstruction"
			Blend One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
            
        	HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            

        	// -------------------------------------
            // Lightweight Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            
        	// -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
        	#pragma fragment frag

        	#define _NORMALMAP 1


        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"

            CBUFFER_START(UnityPerMaterial)
			uniform float _Normalpositiondeviation;
			uniform float _Frequency;
			uniform float _Amplitude;
			uniform sampler2D _Flagalbedo;
			uniform float4 _Flagalbedo_ST;
			CBUFFER_END
			
			
            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
                float4 ase_tangent : TANGENT;
                float4 texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct GraphVertexOutput
            {
                float4 clipPos                : SV_POSITION;
                float4 lightmapUVOrVertexSH	  : TEXCOORD0;
        		half4 fogFactorAndVertexLight : TEXCOORD1; // x: fogFactor, yzw: vertex light
            	float4 shadowCoord            : TEXCOORD2;
				float4 tSpace0					: TEXCOORD3;
				float4 tSpace1					: TEXCOORD4;
				float4 tSpace2					: TEXCOORD5;
				float4 ase_texcoord7 : TEXCOORD7;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            	UNITY_VERTEX_OUTPUT_STEREO
            };


            GraphVertexOutput vert (GraphVertexInput v)
        	{
        		GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
            	UNITY_TRANSFER_INSTANCE_ID(v, o);
        		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float deviation199 = _Normalpositiondeviation;
				float3 appendResult206 = (float3(0.0 , deviation199 , 0.0));
				float3x3 ObjectToTangent121 = float3x3(cross( v.ase_normal , v.ase_tangent.xyz ), v.ase_tangent.xyz, v.ase_normal);
				float3 break3_g18 = mul( ( appendResult206 + mul( ObjectToTangent121, v.vertex.xyz ) ), ObjectToTangent121 );
				float frequency291 = _Frequency;
				float mulTime4_g18 = _Time.y * 2.0;
				float amplitude287 = _Amplitude;
				float3 appendResult11_g18 = (float3(break3_g18.x , ( break3_g18.y + ( sin( ( ( break3_g18.x * frequency291 ) + mulTime4_g18 ) ) * ( amplitude287 * v.ase_texcoord.x ) ) ) , break3_g18.z));
				float3 yDeviation114 = appendResult11_g18;
				float3 break3_g17 = v.vertex.xyz;
				float mulTime4_g17 = _Time.y * 2.0;
				float3 appendResult11_g17 = (float3(break3_g17.x , ( break3_g17.y + ( sin( ( ( break3_g17.x * frequency291 ) + mulTime4_g17 ) ) * ( amplitude287 * v.ase_texcoord.x ) ) ) , break3_g17.z));
				float3 newVertexPos56 = appendResult11_g17;
				float3 appendResult198 = (float3(deviation199 , 0.0 , 0.0));
				float3 break3_g16 = mul( ( appendResult198 + mul( ObjectToTangent121, v.vertex.xyz ) ), ObjectToTangent121 );
				float mulTime4_g16 = _Time.y * 2.0;
				float3 appendResult11_g16 = (float3(break3_g16.x , ( break3_g16.y + ( sin( ( ( break3_g16.x * frequency291 ) + mulTime4_g16 ) ) * ( amplitude287 * v.ase_texcoord.x ) ) ) , break3_g16.z));
				float3 xDeviation113 = appendResult11_g16;
				float3 normalizeResult97 = normalize( cross( ( yDeviation114 - newVertexPos56 ) , ( xDeviation113 - newVertexPos56 ) ) );
				
				o.ase_texcoord7.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				v.vertex.xyz += normalizeResult97;
				v.ase_normal = newVertexPos56;

        		// Vertex shader outputs defined by graph
                float3 lwWNormal = TransformObjectToWorldNormal(v.ase_normal);
				float3 lwWorldPos = TransformObjectToWorld(v.vertex.xyz);
				float3 lwWTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float3 lwWBinormal = normalize(cross(lwWNormal, lwWTangent) * v.ase_tangent.w);
				o.tSpace0 = float4(lwWTangent.x, lwWBinormal.x, lwWNormal.x, lwWorldPos.x);
				o.tSpace1 = float4(lwWTangent.y, lwWBinormal.y, lwWNormal.y, lwWorldPos.y);
				o.tSpace2 = float4(lwWTangent.z, lwWBinormal.z, lwWNormal.z, lwWorldPos.z);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                
         		// We either sample GI from lightmap or SH.
        	    // Lightmap UV and vertex SH coefficients use the same interpolator ("float2 lightmapUV" for lightmap or "half3 vertexSH" for SH)
                // see DECLARE_LIGHTMAP_OR_SH macro.
        	    // The following funcions initialize the correct variable with correct data
        	    OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
        	    OUTPUT_SH(lwWNormal, o.lightmapUVOrVertexSH.xyz);

        	    half3 vertexLight = VertexLighting(vertexInput.positionWS, lwWNormal);
        	    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
        	    o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
        	    o.clipPos = vertexInput.positionCS;

        	#ifdef _MAIN_LIGHT_SHADOWS
        		o.shadowCoord = GetShadowCoord(vertexInput);
        	#endif
        		return o;
        	}

        	half4 frag (GraphVertexOutput IN , half ase_vface : VFACE) : SV_Target
            {
            	UNITY_SETUP_INSTANCE_ID(IN);

        		float3 WorldSpaceNormal = normalize(float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z));
				float3 WorldSpaceTangent = float3(IN.tSpace0.x,IN.tSpace1.x,IN.tSpace2.x);
				float3 WorldSpaceBiTangent = float3(IN.tSpace0.y,IN.tSpace1.y,IN.tSpace2.y);
				float3 WorldSpacePosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldSpaceViewDirection = SafeNormalize( _WorldSpaceCameraPos.xyz  - WorldSpacePosition );
    
				float2 uv_Flagalbedo = IN.ase_texcoord7.xy * _Flagalbedo_ST.xy + _Flagalbedo_ST.zw;
				
				float3 switchResult315 = (((ase_vface>0)?(float3(0,0,1)):(float3(0,0,-1))));
				
				
		        float3 Albedo = tex2D( _Flagalbedo, uv_Flagalbedo ).rgb;
				float3 Normal = switchResult315;
				float3 Emission = 0;
				float3 Specular = float3(0.5, 0.5, 0.5);
				float Metallic = 0;
				float Smoothness = 0.5;
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0;

        		InputData inputData;
        		inputData.positionWS = WorldSpacePosition;

        #ifdef _NORMALMAP
        	    inputData.normalWS = normalize(TransformTangentToWorld(Normal, half3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal)));
        #else
            #if !SHADER_HINT_NICE_QUALITY
                inputData.normalWS = WorldSpaceNormal;
            #else
        	    inputData.normalWS = normalize(WorldSpaceNormal);
            #endif
        #endif

        #if !SHADER_HINT_NICE_QUALITY
        	    // viewDirection should be normalized here, but we avoid doing it as it's close enough and we save some ALU.
        	    inputData.viewDirectionWS = WorldSpaceViewDirection;
        #else
        	    inputData.viewDirectionWS = normalize(WorldSpaceViewDirection);
        #endif

        	    inputData.shadowCoord = IN.shadowCoord;

        	    inputData.fogCoord = IN.fogFactorAndVertexLight.x;
        	    inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
        	    inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, IN.lightmapUVOrVertexSH.xyz, inputData.normalWS);

        		half4 color = LightweightFragmentPBR(
        			inputData, 
        			Albedo, 
        			Metallic, 
        			Specular, 
        			Smoothness, 
        			Occlusion, 
        			Emission, 
        			Alpha);

			#ifdef TERRAIN_SPLAT_ADDPASS
				color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
			#else
				color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
			#endif

        #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif

		#if ASE_LW_FINAL_COLOR_ALPHA_MULTIPLY
				color.rgb *= color.a;
		#endif
        		return color;
            }

        	ENDHLSL
        }

		
        Pass
        {
			
        	Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #define _NORMALMAP 1


            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            CBUFFER_START(UnityPerMaterial)
			uniform float _Normalpositiondeviation;
			uniform float _Frequency;
			uniform float _Amplitude;
			CBUFFER_END
			
			
            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
        	};

            // x: global clip space bias, y: normal world space bias
            float4 _ShadowBias;
            float3 _LightDirection;

            VertexOutput ShadowPassVertex(GraphVertexInput v)
        	{
        	    VertexOutput o;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

				float deviation199 = _Normalpositiondeviation;
				float3 appendResult206 = (float3(0.0 , deviation199 , 0.0));
				float3x3 ObjectToTangent121 = float3x3(cross( v.ase_normal , v.ase_tangent.xyz ), v.ase_tangent.xyz, v.ase_normal);
				float3 break3_g18 = mul( ( appendResult206 + mul( ObjectToTangent121, v.vertex.xyz ) ), ObjectToTangent121 );
				float frequency291 = _Frequency;
				float mulTime4_g18 = _Time.y * 2.0;
				float amplitude287 = _Amplitude;
				float3 appendResult11_g18 = (float3(break3_g18.x , ( break3_g18.y + ( sin( ( ( break3_g18.x * frequency291 ) + mulTime4_g18 ) ) * ( amplitude287 * v.ase_texcoord.x ) ) ) , break3_g18.z));
				float3 yDeviation114 = appendResult11_g18;
				float3 break3_g17 = v.vertex.xyz;
				float mulTime4_g17 = _Time.y * 2.0;
				float3 appendResult11_g17 = (float3(break3_g17.x , ( break3_g17.y + ( sin( ( ( break3_g17.x * frequency291 ) + mulTime4_g17 ) ) * ( amplitude287 * v.ase_texcoord.x ) ) ) , break3_g17.z));
				float3 newVertexPos56 = appendResult11_g17;
				float3 appendResult198 = (float3(deviation199 , 0.0 , 0.0));
				float3 break3_g16 = mul( ( appendResult198 + mul( ObjectToTangent121, v.vertex.xyz ) ), ObjectToTangent121 );
				float mulTime4_g16 = _Time.y * 2.0;
				float3 appendResult11_g16 = (float3(break3_g16.x , ( break3_g16.y + ( sin( ( ( break3_g16.x * frequency291 ) + mulTime4_g16 ) ) * ( amplitude287 * v.ase_texcoord.x ) ) ) , break3_g16.z));
				float3 xDeviation113 = appendResult11_g16;
				float3 normalizeResult97 = normalize( cross( ( yDeviation114 - newVertexPos56 ) , ( xDeviation113 - newVertexPos56 ) ) );
				

				v.vertex.xyz += normalizeResult97;
				v.ase_normal = newVertexPos56;

        	    float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

                float invNdotL = 1.0 - saturate(dot(_LightDirection, normalWS));
                float scale = invNdotL * _ShadowBias.y;

                // normal bias is negative since we want to apply an inset normal offset
                positionWS = normalWS * scale.xxx + positionWS;
                float4 clipPos = TransformWorldToHClip(positionWS);

                // _ShadowBias.x sign depens on if platform has reversed z buffer
                clipPos.z += _ShadowBias.x;

        	#if UNITY_REVERSED_Z
        	    clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
        	#else
        	    clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
        	#endif
                o.clipPos = clipPos;

        	    return o;
        	}

            half4 ShadowPassFragment(VertexOutput IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

               

				float Alpha = 1;
				float AlphaClipThreshold = AlphaClipThreshold;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif
                return 0;
            }

            ENDHLSL
        }

		
        Pass
        {
			
        	Name "DepthOnly"
            Tags { "LightMode"="DepthOnly" }

            ZWrite On
			ColorMask 0

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            #define _NORMALMAP 1


            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			CBUFFER_START(UnityPerMaterial)
			uniform float _Normalpositiondeviation;
			uniform float _Frequency;
			uniform float _Amplitude;
			CBUFFER_END
			
			
           
            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
        	};

            VertexOutput vert(GraphVertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float deviation199 = _Normalpositiondeviation;
				float3 appendResult206 = (float3(0.0 , deviation199 , 0.0));
				float3x3 ObjectToTangent121 = float3x3(cross( v.ase_normal , v.ase_tangent.xyz ), v.ase_tangent.xyz, v.ase_normal);
				float3 break3_g18 = mul( ( appendResult206 + mul( ObjectToTangent121, v.vertex.xyz ) ), ObjectToTangent121 );
				float frequency291 = _Frequency;
				float mulTime4_g18 = _Time.y * 2.0;
				float amplitude287 = _Amplitude;
				float3 appendResult11_g18 = (float3(break3_g18.x , ( break3_g18.y + ( sin( ( ( break3_g18.x * frequency291 ) + mulTime4_g18 ) ) * ( amplitude287 * v.ase_texcoord.x ) ) ) , break3_g18.z));
				float3 yDeviation114 = appendResult11_g18;
				float3 break3_g17 = v.vertex.xyz;
				float mulTime4_g17 = _Time.y * 2.0;
				float3 appendResult11_g17 = (float3(break3_g17.x , ( break3_g17.y + ( sin( ( ( break3_g17.x * frequency291 ) + mulTime4_g17 ) ) * ( amplitude287 * v.ase_texcoord.x ) ) ) , break3_g17.z));
				float3 newVertexPos56 = appendResult11_g17;
				float3 appendResult198 = (float3(deviation199 , 0.0 , 0.0));
				float3 break3_g16 = mul( ( appendResult198 + mul( ObjectToTangent121, v.vertex.xyz ) ), ObjectToTangent121 );
				float mulTime4_g16 = _Time.y * 2.0;
				float3 appendResult11_g16 = (float3(break3_g16.x , ( break3_g16.y + ( sin( ( ( break3_g16.x * frequency291 ) + mulTime4_g16 ) ) * ( amplitude287 * v.ase_texcoord.x ) ) ) , break3_g16.z));
				float3 xDeviation113 = appendResult11_g16;
				float3 normalizeResult97 = normalize( cross( ( yDeviation114 - newVertexPos56 ) , ( xDeviation113 - newVertexPos56 ) ) );
				

				v.vertex.xyz += normalizeResult97;
				v.ase_normal = newVertexPos56;

        	    o.clipPos = TransformObjectToHClip(v.vertex.xyz);
        	    return o;
            }

            half4 frag(VertexOutput IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

				

				float Alpha = 1;
				float AlphaClipThreshold = AlphaClipThreshold;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif
                return 0;
            }
            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
		
        Pass
        {
			
        	Name "Meta"
            Tags { "LightMode"="Meta" }

            Cull Off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            

            #pragma vertex vert
            #pragma fragment frag


            #define _NORMALMAP 1


			uniform float4 _MainTex_ST;

            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/MetaInput.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			CBUFFER_START(UnityPerMaterial)
			uniform float _Normalpositiondeviation;
			uniform float _Frequency;
			uniform float _Amplitude;
			uniform sampler2D _Flagalbedo;
			uniform float4 _Flagalbedo_ST;
			CBUFFER_END
			
			
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature EDITOR_VISUALIZATION


            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
        	};

            VertexOutput vert(GraphVertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				float deviation199 = _Normalpositiondeviation;
				float3 appendResult206 = (float3(0.0 , deviation199 , 0.0));
				float3x3 ObjectToTangent121 = float3x3(cross( v.ase_normal , v.ase_tangent.xyz ), v.ase_tangent.xyz, v.ase_normal);
				float3 break3_g18 = mul( ( appendResult206 + mul( ObjectToTangent121, v.vertex.xyz ) ), ObjectToTangent121 );
				float frequency291 = _Frequency;
				float mulTime4_g18 = _Time.y * 2.0;
				float amplitude287 = _Amplitude;
				float3 appendResult11_g18 = (float3(break3_g18.x , ( break3_g18.y + ( sin( ( ( break3_g18.x * frequency291 ) + mulTime4_g18 ) ) * ( amplitude287 * v.ase_texcoord.x ) ) ) , break3_g18.z));
				float3 yDeviation114 = appendResult11_g18;
				float3 break3_g17 = v.vertex.xyz;
				float mulTime4_g17 = _Time.y * 2.0;
				float3 appendResult11_g17 = (float3(break3_g17.x , ( break3_g17.y + ( sin( ( ( break3_g17.x * frequency291 ) + mulTime4_g17 ) ) * ( amplitude287 * v.ase_texcoord.x ) ) ) , break3_g17.z));
				float3 newVertexPos56 = appendResult11_g17;
				float3 appendResult198 = (float3(deviation199 , 0.0 , 0.0));
				float3 break3_g16 = mul( ( appendResult198 + mul( ObjectToTangent121, v.vertex.xyz ) ), ObjectToTangent121 );
				float mulTime4_g16 = _Time.y * 2.0;
				float3 appendResult11_g16 = (float3(break3_g16.x , ( break3_g16.y + ( sin( ( ( break3_g16.x * frequency291 ) + mulTime4_g16 ) ) * ( amplitude287 * v.ase_texcoord.x ) ) ) , break3_g16.z));
				float3 xDeviation113 = appendResult11_g16;
				float3 normalizeResult97 = normalize( cross( ( yDeviation114 - newVertexPos56 ) , ( xDeviation113 - newVertexPos56 ) ) );
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;

				v.vertex.xyz += normalizeResult97;
				v.ase_normal = newVertexPos56;
				
                o.clipPos = MetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST);
        	    return o;
            }

            half4 frag(VertexOutput IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

           		float2 uv_Flagalbedo = IN.ase_texcoord.xy * _Flagalbedo_ST.xy + _Flagalbedo_ST.zw;
           		
				
		        float3 Albedo = tex2D( _Flagalbedo, uv_Flagalbedo ).rgb;
				float3 Emission = 0;
				float Alpha = 1;
				float AlphaClipThreshold = 0;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif

                MetaInput metaInput = (MetaInput)0;
                metaInput.Albedo = Albedo;
                metaInput.Emission = Emission;
                
                return MetaFragment(metaInput);
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/InternalErrorShader"
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16100
-1913;7;1429;1044;-933.3188;1066.165;1.135;True;True
Node;AmplifyShaderEditor.CommentaryNode;296;-3621.198,212.0746;Float;False;1078.618;465.5402;object to tangent matrix without tangent sign;5;116;121;125;118;117;Object to tangent matrix;1,1,1,1;0;0
Node;AmplifyShaderEditor.TangentVertexDataNode;118;-3574.62,369.6892;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;117;-3565.198,513.2958;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;295;-2853.043,-482.4444;Float;False;645.3955;379.0187;Comment;6;130;199;127;291;112;287;Inputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.CrossProductOpNode;125;-3222.62,305.6892;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.MatrixFromVectors;116;-3046.62,337.6892;Float;False;FLOAT3x3;True;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-2800,-224;Float;False;Property;_Normalpositiondeviation;Normal position deviation;2;0;Create;True;0;0;False;0;0.1;0.1;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;202;-1552,192;Float;False;1552.676;586.3004;move the position in tangent Y direction by the deviation amount;14;311;310;114;313;292;210;288;209;208;206;207;205;203;204;delta Y position;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;177;-1568,-528;Float;False;1562.402;582.1888;move the position in tangent X direction by the deviation amount;14;308;289;314;309;113;197;293;196;195;198;194;192;200;201;delta X position;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;199;-2480,-224;Float;False;deviation;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;121;-2790.62,337.6892;Float;False;ObjectToTangent;-1;True;1;0;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;-1456,288;Float;False;199;deviation;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;-1504,400;Float;False;121;ObjectToTangent;1;0;OBJECT;0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.PosVertexDataNode;201;-1472,-208;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;192;-1511.005,-316.4977;Float;False;121;ObjectToTangent;1;0;OBJECT;0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.GetLocalVarNode;200;-1472,-432;Float;False;199;deviation;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;205;-1472,496;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;112;-2800,-416;Float;False;Property;_Amplitude;Amplitude;0;0;Create;True;0;0;False;0;0;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;77;-1568,-1184;Float;False;959.9028;475.1613;simply apply vertex transformation;7;56;312;15;306;294;290;307;new vertex position;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;287;-2480,-416;Float;False;amplitude;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-2688,-320;Float;False;Property;_Frequency;Frequency;1;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;206;-1216,320;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;207;-1216,448;Float;False;2;2;0;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;198;-1216,-416;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;-1216,-288;Float;False;2;2;0;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;290;-1456,-960;Float;False;287;amplitude;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;307;-1472,-880;Float;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;288;-800,560;Float;False;287;amplitude;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;309;-784,-96;Float;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;289;-768,-176;Float;False;287;amplitude;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;311;-800,640;Float;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;195;-1024,-368;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;196;-1072,-224;Float;False;121;ObjectToTangent;1;0;OBJECT;0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;209;-1024,368;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;-1072,528;Float;False;121;ObjectToTangent;1;0;OBJECT;0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;291;-2480,-320;Float;False;frequency;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;15;-1520,-1104;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;292;-800,480;Float;False;291;frequency;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;197;-736,-368;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;293;-768,-256;Float;False;291;frequency;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;306;-1232,-960;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;310;-592,528;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;294;-1332.203,-1039.546;Float;False;291;frequency;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;308;-560,-192;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;210;-784,368;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;314;-432,-368;Float;False;Waving Vertex;-1;;16;872b3757863bb794c96291ceeebfb188;0;3;1;FLOAT3;0,0,0;False;12;FLOAT;0;False;13;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;312;-1056,-1104;Float;False;Waving Vertex;-1;;17;872b3757863bb794c96291ceeebfb188;0;3;1;FLOAT3;0,0,0;False;12;FLOAT;0;False;13;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;313;-480,368;Float;False;Waving Vertex;-1;;18;872b3757863bb794c96291ceeebfb188;0;3;1;FLOAT3;0,0,0;False;12;FLOAT;0;False;13;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;297;657.8127,-173.1141;Float;False;927.4102;507.1851;calculated new normal by derivation;8;223;107;224;108;88;93;96;97;new normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;113;-240,-368;Float;False;xDeviation;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;-832,-1104;Float;False;newVertexPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;-240,368;Float;False;yDeviation;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;224;707.4468,113.0864;Float;False;114;yDeviation;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;707.8127,-6.447388;Float;False;56;newVertexPos;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;707.4468,193.0864;Float;False;56;newVertexPos;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;223;707.4468,-78.91376;Float;False;113;xDeviation;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;93;979.4468,113.0864;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;88;979.4468,-62.91375;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;318;1155.447,-846.9138;Float;False;461.3383;368.4299;Fix normals for back side faces;3;315;317;316;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CrossProductOpNode;96;1171.447,17.08633;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwitchByFaceNode;315;1459.447,-718.9138;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;305;1325.821,-1067.025;Float;True;Property;_Flagalbedo;Flag albedo;3;0;Create;True;0;0;False;0;None;8aba6bb20faf8824d9d81946542f1ce1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;19;1379.447,-462.9138;Float;False;Constant;_Smoothness;Smoothness;0;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;1363.447,-366.9138;Float;False;56;newVertexPos;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;317;1171.447,-638.9138;Float;False;Constant;_Backnormalvector;Back normal vector;4;0;Create;True;0;0;False;0;0,0,-1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;316;1171.447,-798.9138;Float;False;Constant;_Frontnormalvector;Front normal vector;4;0;Create;True;0;0;False;0;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;97;1395.447,17.08633;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;321;1895.744,-699.7397;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;2;DepthOnly;0;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;319;1895.744,-699.7397;Float;False;True;2;Float;ASEMaterialInspector;0;2;ASESampleShaders/VertexNormalReconstruction;1976390536c6c564abb90fe41f6ee334;0;0;VertexNormalReconstruction;11;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;;0;0;Standard;1;_FinalColorxAlpha;0;11;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;9;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT3;0,0,0;False;10;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;320;1895.744,-699.7397;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;1;ShadowCaster;0;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;322;1895.744,-699.7397;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;3;Meta;0;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;;0;0;Standard;0;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;0
WireConnection;125;0;117;0
WireConnection;125;1;118;0
WireConnection;116;0;125;0
WireConnection;116;1;118;0
WireConnection;116;2;117;0
WireConnection;199;0;130;0
WireConnection;121;0;116;0
WireConnection;287;0;112;0
WireConnection;206;1;203;0
WireConnection;207;0;204;0
WireConnection;207;1;205;0
WireConnection;198;0;200;0
WireConnection;194;0;192;0
WireConnection;194;1;201;0
WireConnection;195;0;198;0
WireConnection;195;1;194;0
WireConnection;209;0;206;0
WireConnection;209;1;207;0
WireConnection;291;0;127;0
WireConnection;197;0;195;0
WireConnection;197;1;196;0
WireConnection;306;0;290;0
WireConnection;306;1;307;1
WireConnection;310;0;288;0
WireConnection;310;1;311;1
WireConnection;308;0;289;0
WireConnection;308;1;309;1
WireConnection;210;0;209;0
WireConnection;210;1;208;0
WireConnection;314;1;197;0
WireConnection;314;12;293;0
WireConnection;314;13;308;0
WireConnection;312;1;15;0
WireConnection;312;12;294;0
WireConnection;312;13;306;0
WireConnection;313;1;210;0
WireConnection;313;12;292;0
WireConnection;313;13;310;0
WireConnection;113;0;314;0
WireConnection;56;0;312;0
WireConnection;114;0;313;0
WireConnection;93;0;224;0
WireConnection;93;1;108;0
WireConnection;88;0;223;0
WireConnection;88;1;107;0
WireConnection;96;0;93;0
WireConnection;96;1;88;0
WireConnection;315;0;316;0
WireConnection;315;1;317;0
WireConnection;97;0;96;0
WireConnection;319;0;305;0
WireConnection;319;1;315;0
WireConnection;319;4;19;0
WireConnection;319;8;97;0
WireConnection;319;10;109;0
ASEEND*/
//CHKSM=C95215327E251F4ECF47821E4E908A50731256AD