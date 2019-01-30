// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASESampleShaders/Community/Gaxil/Melting"
{
    Properties
    {
		[HDR]_BaseColor("Base Color", Color) = (0.05136246,0.1295507,0.2794118,0)
		[NoScaleOffset]_BaseNormal("Base Normal", 2D) = "bump" {}
		[HDR]_Color1("Color 1", Color) = (1,0,0,0)
		[HDR]_Color2("Color 2", Color) = (1,1,0,0)
		[NoScaleOffset]_DisplaceNoise("Displace Noise", 2D) = "white" {}
		_NoiseScale("NoiseScale", Range( 0 , 0.1)) = 0
		_Limit("Limit", Range( 0 , 3)) = 2
		_Oscillation("Oscillation", Range( 0 , 3)) = 2
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_NoiseMultiply("Noise Multiply", Float) = 0
		[Toggle]_AnimatedMelt("Animated Melt", Float) = 1
		_ManualControl("Manual Control", Float) = 0
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

        	Name "Melting"
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
			uniform sampler2D _DisplaceNoise;
			uniform half _AnimatedMelt;
			uniform half _ManualControl;
			uniform half _Oscillation;
			uniform half _Limit;
			uniform half _NoiseScale;
			uniform half _NoiseMultiply;
			uniform half4 _BaseColor;
			uniform sampler2D _BaseNormal;
			uniform half4 _Color1;
			uniform half4 _Color2;
			uniform half _Metallic;
			uniform half _Smoothness;
			CBUFFER_END
			
			float4 CalculateContrast( float contrastValue, float4 colorTarget )
			{
				float t = 0.5 * ( 1.0 - contrastValue );
				return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
			}

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
				float4 ase_texcoord8 : TEXCOORD8;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            	UNITY_VERTEX_OUTPUT_STEREO
            };


            GraphVertexOutput vert (GraphVertexInput v)
        	{
        		GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
            	UNITY_TRANSFER_INSTANCE_ID(v, o);
        		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float dotResult78 = dot( v.ase_normal , half3(0,1,0) );
				float2 appendResult61 = (half2(( v.vertex.xyz.x + lerp(_ManualControl,( ( _SinTime.z * _Oscillation ) + _Limit ),_AnimatedMelt) ) , v.vertex.xyz.z));
				half4 tex2DNode58 = tex2Dlod( _DisplaceNoise, half4( ( appendResult61 * _NoiseScale ), 0, 0.0) );
				float temp_output_72_0 = ( ( tex2DNode58.g * _NoiseMultiply ) + lerp(_ManualControl,( ( _SinTime.z * _Oscillation ) + _Limit ),_AnimatedMelt) );
				float Vertex1106 = v.vertex.xyz.y;
				float4 appendResult82 = (half4(0.0 , ( ( dotResult78 * 0.05 ) + min( ( temp_output_72_0 - Vertex1106 ) , 0.0 ) ) , 0.0 , 0.0));
				float smoothstepResult88 = smoothstep( ( temp_output_72_0 - 0.2 ) , ( temp_output_72_0 + 0.2 ) , Vertex1106);
				float SmoothStep2112 = smoothstepResult88;
				
				o.ase_texcoord7 = v.vertex;
				o.ase_texcoord8.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord8.zw = 0;
				v.vertex.xyz += ( appendResult82 * SmoothStep2112 ).xyz;
				v.ase_normal =  v.ase_normal ;

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

        	half4 frag (GraphVertexOutput IN ) : SV_Target
            {
            	UNITY_SETUP_INSTANCE_ID(IN);

        		float3 WorldSpaceNormal = normalize(float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z));
				float3 WorldSpaceTangent = float3(IN.tSpace0.x,IN.tSpace1.x,IN.tSpace2.x);
				float3 WorldSpaceBiTangent = float3(IN.tSpace0.y,IN.tSpace1.y,IN.tSpace2.y);
				float3 WorldSpacePosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldSpaceViewDirection = SafeNormalize( _WorldSpaceCameraPos.xyz  - WorldSpacePosition );
    
				float2 appendResult61 = (half2(( IN.ase_texcoord7.xyz.x + lerp(_ManualControl,( ( _SinTime.z * _Oscillation ) + _Limit ),_AnimatedMelt) ) , IN.ase_texcoord7.xyz.z));
				half4 tex2DNode58 = tex2D( _DisplaceNoise, ( appendResult61 * _NoiseScale ) );
				float temp_output_72_0 = ( ( tex2DNode58.g * _NoiseMultiply ) + lerp(_ManualControl,( ( _SinTime.z * _Oscillation ) + _Limit ),_AnimatedMelt) );
				float Vertex1106 = IN.ase_texcoord7.xyz.y;
				float smoothstepResult92 = smoothstep( ( temp_output_72_0 - 0.5 ) , ( temp_output_72_0 + 0.5 ) , Vertex1106);
				float SmoothStep1110 = smoothstepResult92;
				
				float2 uv_BaseNormal122 = IN.ase_texcoord8.xy;
				
				half4 temp_cast_1 = (tex2DNode58.g).xxxx;
				float smoothstepResult88 = smoothstep( ( temp_output_72_0 - 0.2 ) , ( temp_output_72_0 + 0.2 ) , Vertex1106);
				float SmoothStep2112 = smoothstepResult88;
				float4 lerpResult56 = lerp( _Color1 , ( _Color2 * CalculateContrast(0.0,temp_cast_1) ) , SmoothStep2112);
				
				
		        float3 Albedo = ( _BaseColor * saturate( ( 1.0 - ( 5.0 * SmoothStep1110 ) ) ) ).rgb;
				float3 Normal = UnpackNormalmapRGorAG( tex2D( _BaseNormal, uv_BaseNormal122 ), 1.0f );
				float3 Emission = ( lerpResult56 * SmoothStep1110 ).rgb;
				float3 Specular = float3(0.5, 0.5, 0.5);
				float Metallic = _Metallic;
				float Smoothness = _Smoothness;
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

            

            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            CBUFFER_START(UnityPerMaterial)
			uniform sampler2D _DisplaceNoise;
			uniform half _AnimatedMelt;
			uniform half _ManualControl;
			uniform half _Oscillation;
			uniform half _Limit;
			uniform half _NoiseScale;
			uniform half _NoiseMultiply;
			CBUFFER_END
			
			
            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
				
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

				float dotResult78 = dot( v.ase_normal , half3(0,1,0) );
				float2 appendResult61 = (half2(( v.vertex.xyz.x + lerp(_ManualControl,( ( _SinTime.z * _Oscillation ) + _Limit ),_AnimatedMelt) ) , v.vertex.xyz.z));
				half4 tex2DNode58 = tex2Dlod( _DisplaceNoise, half4( ( appendResult61 * _NoiseScale ), 0, 0.0) );
				float temp_output_72_0 = ( ( tex2DNode58.g * _NoiseMultiply ) + lerp(_ManualControl,( ( _SinTime.z * _Oscillation ) + _Limit ),_AnimatedMelt) );
				float Vertex1106 = v.vertex.xyz.y;
				float4 appendResult82 = (half4(0.0 , ( ( dotResult78 * 0.05 ) + min( ( temp_output_72_0 - Vertex1106 ) , 0.0 ) ) , 0.0 , 0.0));
				float smoothstepResult88 = smoothstep( ( temp_output_72_0 - 0.2 ) , ( temp_output_72_0 + 0.2 ) , Vertex1106);
				float SmoothStep2112 = smoothstepResult88;
				

				v.vertex.xyz += ( appendResult82 * SmoothStep2112 ).xyz;
				v.ase_normal =  v.ase_normal ;

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

            

            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			CBUFFER_START(UnityPerMaterial)
			uniform sampler2D _DisplaceNoise;
			uniform half _AnimatedMelt;
			uniform half _ManualControl;
			uniform half _Oscillation;
			uniform half _Limit;
			uniform half _NoiseScale;
			uniform half _NoiseMultiply;
			CBUFFER_END
			
			
           
            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
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

				float dotResult78 = dot( v.ase_normal , half3(0,1,0) );
				float2 appendResult61 = (half2(( v.vertex.xyz.x + lerp(_ManualControl,( ( _SinTime.z * _Oscillation ) + _Limit ),_AnimatedMelt) ) , v.vertex.xyz.z));
				half4 tex2DNode58 = tex2Dlod( _DisplaceNoise, half4( ( appendResult61 * _NoiseScale ), 0, 0.0) );
				float temp_output_72_0 = ( ( tex2DNode58.g * _NoiseMultiply ) + lerp(_ManualControl,( ( _SinTime.z * _Oscillation ) + _Limit ),_AnimatedMelt) );
				float Vertex1106 = v.vertex.xyz.y;
				float4 appendResult82 = (half4(0.0 , ( ( dotResult78 * 0.05 ) + min( ( temp_output_72_0 - Vertex1106 ) , 0.0 ) ) , 0.0 , 0.0));
				float smoothstepResult88 = smoothstep( ( temp_output_72_0 - 0.2 ) , ( temp_output_72_0 + 0.2 ) , Vertex1106);
				float SmoothStep2112 = smoothstepResult88;
				

				v.vertex.xyz += ( appendResult82 * SmoothStep2112 ).xyz;
				v.ase_normal =  v.ase_normal ;

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


            

			uniform float4 _MainTex_ST;

            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/MetaInput.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			CBUFFER_START(UnityPerMaterial)
			uniform sampler2D _DisplaceNoise;
			uniform half _AnimatedMelt;
			uniform half _ManualControl;
			uniform half _Oscillation;
			uniform half _Limit;
			uniform half _NoiseScale;
			uniform half _NoiseMultiply;
			uniform half4 _BaseColor;
			uniform half4 _Color1;
			uniform half4 _Color2;
			CBUFFER_END
			
			float4 CalculateContrast( float contrastValue, float4 colorTarget )
			{
				float t = 0.5 * ( 1.0 - contrastValue );
				return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
			}

            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature EDITOR_VISUALIZATION


            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				
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
				float dotResult78 = dot( v.ase_normal , half3(0,1,0) );
				float2 appendResult61 = (half2(( v.vertex.xyz.x + lerp(_ManualControl,( ( _SinTime.z * _Oscillation ) + _Limit ),_AnimatedMelt) ) , v.vertex.xyz.z));
				half4 tex2DNode58 = tex2Dlod( _DisplaceNoise, half4( ( appendResult61 * _NoiseScale ), 0, 0.0) );
				float temp_output_72_0 = ( ( tex2DNode58.g * _NoiseMultiply ) + lerp(_ManualControl,( ( _SinTime.z * _Oscillation ) + _Limit ),_AnimatedMelt) );
				float Vertex1106 = v.vertex.xyz.y;
				float4 appendResult82 = (half4(0.0 , ( ( dotResult78 * 0.05 ) + min( ( temp_output_72_0 - Vertex1106 ) , 0.0 ) ) , 0.0 , 0.0));
				float smoothstepResult88 = smoothstep( ( temp_output_72_0 - 0.2 ) , ( temp_output_72_0 + 0.2 ) , Vertex1106);
				float SmoothStep2112 = smoothstepResult88;
				
				o.ase_texcoord = v.vertex;

				v.vertex.xyz += ( appendResult82 * SmoothStep2112 ).xyz;
				v.ase_normal =  v.ase_normal ;
				
                o.clipPos = MetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST);
        	    return o;
            }

            half4 frag(VertexOutput IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

           		float2 appendResult61 = (half2(( IN.ase_texcoord.xyz.x + lerp(_ManualControl,( ( _SinTime.z * _Oscillation ) + _Limit ),_AnimatedMelt) ) , IN.ase_texcoord.xyz.z));
           		half4 tex2DNode58 = tex2D( _DisplaceNoise, ( appendResult61 * _NoiseScale ) );
           		float temp_output_72_0 = ( ( tex2DNode58.g * _NoiseMultiply ) + lerp(_ManualControl,( ( _SinTime.z * _Oscillation ) + _Limit ),_AnimatedMelt) );
           		float Vertex1106 = IN.ase_texcoord.xyz.y;
           		float smoothstepResult92 = smoothstep( ( temp_output_72_0 - 0.5 ) , ( temp_output_72_0 + 0.5 ) , Vertex1106);
           		float SmoothStep1110 = smoothstepResult92;
           		
           		half4 temp_cast_1 = (tex2DNode58.g).xxxx;
           		float smoothstepResult88 = smoothstep( ( temp_output_72_0 - 0.2 ) , ( temp_output_72_0 + 0.2 ) , Vertex1106);
           		float SmoothStep2112 = smoothstepResult88;
           		float4 lerpResult56 = lerp( _Color1 , ( _Color2 * CalculateContrast(0.0,temp_cast_1) ) , SmoothStep2112);
           		
				
		        float3 Albedo = ( _BaseColor * saturate( ( 1.0 - ( 5.0 * SmoothStep1110 ) ) ) ).rgb;
				float3 Emission = ( lerpResult56 * SmoothStep1110 ).rgb;
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
-1919;1;1442;1056;470.1148;346.6067;1.118487;True;True
Node;AmplifyShaderEditor.SinTimeNode;101;-3810.807,914.866;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;68;-3813.511,1111.719;Float;False;Property;_Oscillation;Oscillation;8;0;Create;True;0;0;False;0;2;2.24;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-3483.519,960.7067;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-3620.55,1231.97;Float;False;Property;_Limit;Limit;7;0;Create;True;0;0;False;0;2;2.78;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-3324.453,832.0427;Float;False;Property;_ManualControl;Manual Control;13;0;Create;True;0;0;False;0;0;0.84;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-3270.364,945.3262;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;103;-3147.019,513.572;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;124;-2988.804,964.5943;Float;False;Property;_AnimatedMelt;Animated Melt;12;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-2700.144,650.3508;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-2538.026,889.3254;Float;False;Property;_NoiseScale;NoiseScale;6;0;Create;True;0;0;False;0;0;0.0527;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;61;-2531.79,763.9691;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-2338.073,713.1436;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;58;-2153.503,727.1264;Float;True;Property;_DisplaceNoise;Displace Noise;5;1;[NoScaleOffset];Create;True;0;0;False;0;None;cd460ee4ac5c1e746b7a734cc7cc64dd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;121;-1974.133,1046.565;Float;False;Property;_NoiseMultiply;Noise Multiply;11;0;Create;True;0;0;False;0;0;1.92;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;70;-1250.901,939.8544;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-1739.151,913.1738;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-1166.786,1657.16;Float;False;Constant;_Float6;Float 6;5;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;-1197.014,1453.799;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;-1036.462,953.9698;Float;False;Vertex1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;90;-883.028,1622.163;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-893.2176,1756.326;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;-904.8461,1532.988;Float;False;106;Vertex1;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;92;-453.3835,1645.252;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-1122.48,1256.421;Float;False;Constant;_Float2;Float 2;5;0;Create;True;0;0;False;0;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;-220.0436,1604.104;Float;False;SmoothStep1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-815.2325,1180.366;Float;False;106;Vertex1;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;74;-796.3981,1264.791;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;77;-1085.352,753.415;Float;False;Constant;_Vector0;Vector 0;5;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalVertexDataNode;76;-1093.539,569.2209;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;75;-757.7103,1383.554;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;85;-767.7754,941.9226;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;88;-567.4893,1335.979;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1132.116,-217.6887;Float;False;Constant;_AlbedoSmoothness;Albedo Smoothness;1;0;Create;True;0;0;False;0;5;14.61;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-762.6805,1045.517;Float;False;Constant;_Float4;Float 4;5;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-823.8184,785.6821;Float;False;Constant;_Float3;Float 3;5;0;Create;True;0;0;False;0;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;78;-835.7063,646.4243;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;111;-1116.777,-123.0787;Float;False;110;SmoothStep1;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;112;-273.1816,1330.431;Float;False;SmoothStep2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;57;-1099.259,384.6501;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMinOpNode;84;-550.3973,921.5436;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-611.5348,666.8034;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-839.1805,-121.5225;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;54;-1124.427,163.7239;Float;False;Property;_Color2;Color 2;4;1;[HDR];Create;True;0;0;False;0;1,1,0,0;12.51701,11.65377,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-395.8549,811.1561;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;49;-654.6093,-104.7433;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-751.7337,380.0894;Float;False;112;SmoothStep2;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;53;-1127.241,-41.60062;Float;False;Property;_Color1;Color 1;3;1;[HDR];Create;True;0;0;False;0;1,0,0,0;1.354,0.3081514,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-794.4365,229.4424;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;52;-1134.215,-431.9377;Float;False;Property;_BaseColor;Base Color;1;1;[HDR];Create;True;0;0;False;0;0.05136246,0.1295507,0.2794118,0;0.2647056,0.2647056,0.2647056,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;56;-513.6298,187.4719;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;48;-425.2932,-113.1329;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;-445.7439,384.5448;Float;False;110;SmoothStep1;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-192.5783,887.3002;Float;False;112;SmoothStep2;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;82;-209.8739,697.6317;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-212.7563,103.5981;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-209.9603,-191.4359;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;115;31.33832,348.154;Float;False;Property;_Smoothness;Smoothness;9;0;Create;True;0;0;False;0;0;0.6536242;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;116;43.33832,235.154;Float;False;Property;_Metallic;Metallic;10;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;59;-3136.419,683.5956;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;45.73086,680.5845;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;122;-240.494,-92.57401;Float;True;Property;_BaseNormal;Base Normal;2;1;[NoScaleOffset];Create;True;0;0;False;0;bd734c29baceb63499732f24fbaea45f;bd734c29baceb63499732f24fbaea45f;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;127;645.6053,-17.79857;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;2;DepthOnly;0;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;125;645.6053,-17.79857;Float;False;True;2;Float;ASEMaterialInspector;0;2;ASESampleShaders/Community/Gaxil/Melting;1976390536c6c564abb90fe41f6ee334;0;0;Melting;11;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;;0;0;Standard;1;_FinalColorxAlpha;0;11;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;9;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT3;0,0,0;False;10;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;126;645.6053,-17.79857;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;1;ShadowCaster;0;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;128;645.6053,-17.79857;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;3;Meta;0;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;;0;0;Standard;0;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;0
WireConnection;67;0;101;3
WireConnection;67;1;68;0
WireConnection;62;0;67;0
WireConnection;62;1;69;0
WireConnection;124;0;123;0
WireConnection;124;1;62;0
WireConnection;60;0;103;1
WireConnection;60;1;124;0
WireConnection;61;0;60;0
WireConnection;61;1;103;3
WireConnection;64;0;61;0
WireConnection;64;1;63;0
WireConnection;58;1;64;0
WireConnection;120;0;58;2
WireConnection;120;1;121;0
WireConnection;72;0;120;0
WireConnection;72;1;124;0
WireConnection;106;0;70;2
WireConnection;90;0;72;0
WireConnection;90;1;89;0
WireConnection;91;0;72;0
WireConnection;91;1;89;0
WireConnection;92;0;108;0
WireConnection;92;1;90;0
WireConnection;92;2;91;0
WireConnection;110;0;92;0
WireConnection;74;0;72;0
WireConnection;74;1;71;0
WireConnection;75;0;72;0
WireConnection;75;1;71;0
WireConnection;85;0;72;0
WireConnection;85;1;106;0
WireConnection;88;0;107;0
WireConnection;88;1;74;0
WireConnection;88;2;75;0
WireConnection;78;0;76;0
WireConnection;78;1;77;0
WireConnection;112;0;88;0
WireConnection;57;1;58;2
WireConnection;84;0;85;0
WireConnection;84;1;86;0
WireConnection;80;0;78;0
WireConnection;80;1;79;0
WireConnection;50;0;51;0
WireConnection;50;1;111;0
WireConnection;81;0;80;0
WireConnection;81;1;84;0
WireConnection;49;0;50;0
WireConnection;55;0;54;0
WireConnection;55;1;57;0
WireConnection;56;0;53;0
WireConnection;56;1;55;0
WireConnection;56;2;114;0
WireConnection;48;0;49;0
WireConnection;82;1;81;0
WireConnection;65;0;56;0
WireConnection;65;1;109;0
WireConnection;47;0;52;0
WireConnection;47;1;48;0
WireConnection;83;0;82;0
WireConnection;83;1;113;0
WireConnection;125;0;47;0
WireConnection;125;1;122;0
WireConnection;125;2;65;0
WireConnection;125;3;116;0
WireConnection;125;4;115;0
WireConnection;125;8;83;0
ASEEND*/
//CHKSM=32B39601DF3FD0C338DB6C37B0E6301B467D2A92