// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASESampleShaders/ProceduralWall"
{
    Properties
    {
		_Slope("Slope", Range( 0 , 0.2)) = 0.4
		_Noise("Noise", 2D) = "white" {}
		_PatternSize("Pattern Size", Vector) = (0,0,0,0)
		_NoiseIntensity("Noise Intensity", Range( 0 , 1)) = 0
		_BrickTiling("Brick Tiling", Float) = 0
		_BrickHeight("Brick Height", Range( 0 , 1)) = 0
		_InnerAlbedo("Inner Albedo", 2D) = "white" {}
		_InnerNormal("Inner Normal", 2D) = "bump" {}
		_BrickAlbedo("Brick Albedo", 2D) = "white" {}
		_BrickNormal("Brick Normal", 2D) = "bump" {}
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

        	Name "ProcuduralWall"
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
			uniform float _NoiseIntensity;
			uniform sampler2D _Noise;
			uniform float4 _Noise_ST;
			uniform float2 _PatternSize;
			uniform float _Slope;
			uniform float _BrickTiling;
			uniform float _BrickHeight;
			uniform sampler2D _InnerAlbedo;
			uniform float4 _InnerAlbedo_ST;
			uniform sampler2D _BrickAlbedo;
			uniform float4 _BrickAlbedo_ST;
			uniform sampler2D _InnerNormal;
			uniform float4 _InnerNormal_ST;
			uniform sampler2D _BrickNormal;
			uniform float4 _BrickNormal_ST;
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

				float2 uv_Noise = v.ase_texcoord * _Noise_ST.xy + _Noise_ST.zw;
				float2 ScaledSize42 = ( float2( 0.5,0.5 ) - ( _PatternSize * 0.5 ) );
				float2 temp_output_6_0 = ( _BrickTiling * v.ase_texcoord.xy );
				float temp_output_10_0 = (temp_output_6_0).y;
				float2 appendResult20 = (float2(( ( step( 1.0 , fmod( temp_output_10_0 , 2.0 ) ) * 0.5 ) + (temp_output_6_0).x ) , temp_output_10_0));
				float2 BrickTile19 = frac( appendResult20 );
				float2 smoothstepResult29 = smoothstep( ScaledSize42 , ( ScaledSize42 + _Slope ) , BrickTile19);
				float2 smoothstepResult32 = smoothstep( ScaledSize42 , ( ScaledSize42 + _Slope ) , ( 1.0 - BrickTile19 ));
				float2 temp_output_48_0 = ( smoothstepResult29 * smoothstepResult32 );
				float BoxValue65 = ( ( _NoiseIntensity * (tex2Dlod( _Noise, float4( uv_Noise, 0, 0.0) ).r*2.0 + -1.0) ) + ( (temp_output_48_0).x * (temp_output_48_0).y ) );
				
				o.ase_texcoord7.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				v.vertex.xyz += ( v.ase_normal * BoxValue65 * _BrickHeight );
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
    
				float2 uv_InnerAlbedo = IN.ase_texcoord7.xy * _InnerAlbedo_ST.xy + _InnerAlbedo_ST.zw;
				float2 uv_BrickAlbedo = IN.ase_texcoord7.xy * _BrickAlbedo_ST.xy + _BrickAlbedo_ST.zw;
				float2 uv_Noise = IN.ase_texcoord7.xy * _Noise_ST.xy + _Noise_ST.zw;
				float2 ScaledSize42 = ( float2( 0.5,0.5 ) - ( _PatternSize * 0.5 ) );
				float2 temp_output_6_0 = ( _BrickTiling * IN.ase_texcoord7.xy );
				float temp_output_10_0 = (temp_output_6_0).y;
				float2 appendResult20 = (float2(( ( step( 1.0 , fmod( temp_output_10_0 , 2.0 ) ) * 0.5 ) + (temp_output_6_0).x ) , temp_output_10_0));
				float2 BrickTile19 = frac( appendResult20 );
				float2 smoothstepResult29 = smoothstep( ScaledSize42 , ( ScaledSize42 + _Slope ) , BrickTile19);
				float2 smoothstepResult32 = smoothstep( ScaledSize42 , ( ScaledSize42 + _Slope ) , ( 1.0 - BrickTile19 ));
				float2 temp_output_48_0 = ( smoothstepResult29 * smoothstepResult32 );
				float BoxValue65 = ( ( _NoiseIntensity * (tex2D( _Noise, uv_Noise ).r*2.0 + -1.0) ) + ( (temp_output_48_0).x * (temp_output_48_0).y ) );
				float4 lerpResult52 = lerp( tex2D( _InnerAlbedo, uv_InnerAlbedo ) , tex2D( _BrickAlbedo, uv_BrickAlbedo ) , BoxValue65);
				
				float2 uv_InnerNormal = IN.ase_texcoord7.xy * _InnerNormal_ST.xy + _InnerNormal_ST.zw;
				float2 uv_BrickNormal = IN.ase_texcoord7.xy * _BrickNormal_ST.xy + _BrickNormal_ST.zw;
				float3 lerpResult55 = lerp( UnpackNormalmapRGorAG( tex2D( _InnerNormal, uv_InnerNormal ), 1.0f ) , UnpackNormalmapRGorAG( tex2D( _BrickNormal, uv_BrickNormal ), 1.0f ) , BoxValue65);
				
				
		        float3 Albedo = lerpResult52.rgb;
				float3 Normal = UnpackNormalmapRGorAG( float4( lerpResult55 , 0.0 ), 1.0 );
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

            

            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            CBUFFER_START(UnityPerMaterial)
			uniform float _NoiseIntensity;
			uniform sampler2D _Noise;
			uniform float4 _Noise_ST;
			uniform float2 _PatternSize;
			uniform float _Slope;
			uniform float _BrickTiling;
			uniform float _BrickHeight;
			CBUFFER_END
			
			
            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
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

				float2 uv_Noise = v.ase_texcoord * _Noise_ST.xy + _Noise_ST.zw;
				float2 ScaledSize42 = ( float2( 0.5,0.5 ) - ( _PatternSize * 0.5 ) );
				float2 temp_output_6_0 = ( _BrickTiling * v.ase_texcoord.xy );
				float temp_output_10_0 = (temp_output_6_0).y;
				float2 appendResult20 = (float2(( ( step( 1.0 , fmod( temp_output_10_0 , 2.0 ) ) * 0.5 ) + (temp_output_6_0).x ) , temp_output_10_0));
				float2 BrickTile19 = frac( appendResult20 );
				float2 smoothstepResult29 = smoothstep( ScaledSize42 , ( ScaledSize42 + _Slope ) , BrickTile19);
				float2 smoothstepResult32 = smoothstep( ScaledSize42 , ( ScaledSize42 + _Slope ) , ( 1.0 - BrickTile19 ));
				float2 temp_output_48_0 = ( smoothstepResult29 * smoothstepResult32 );
				float BoxValue65 = ( ( _NoiseIntensity * (tex2Dlod( _Noise, float4( uv_Noise, 0, 0.0) ).r*2.0 + -1.0) ) + ( (temp_output_48_0).x * (temp_output_48_0).y ) );
				

				v.vertex.xyz += ( v.ase_normal * BoxValue65 * _BrickHeight );
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
			uniform float _NoiseIntensity;
			uniform sampler2D _Noise;
			uniform float4 _Noise_ST;
			uniform float2 _PatternSize;
			uniform float _Slope;
			uniform float _BrickTiling;
			uniform float _BrickHeight;
			CBUFFER_END
			
			
           
            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
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

				float2 uv_Noise = v.ase_texcoord * _Noise_ST.xy + _Noise_ST.zw;
				float2 ScaledSize42 = ( float2( 0.5,0.5 ) - ( _PatternSize * 0.5 ) );
				float2 temp_output_6_0 = ( _BrickTiling * v.ase_texcoord.xy );
				float temp_output_10_0 = (temp_output_6_0).y;
				float2 appendResult20 = (float2(( ( step( 1.0 , fmod( temp_output_10_0 , 2.0 ) ) * 0.5 ) + (temp_output_6_0).x ) , temp_output_10_0));
				float2 BrickTile19 = frac( appendResult20 );
				float2 smoothstepResult29 = smoothstep( ScaledSize42 , ( ScaledSize42 + _Slope ) , BrickTile19);
				float2 smoothstepResult32 = smoothstep( ScaledSize42 , ( ScaledSize42 + _Slope ) , ( 1.0 - BrickTile19 ));
				float2 temp_output_48_0 = ( smoothstepResult29 * smoothstepResult32 );
				float BoxValue65 = ( ( _NoiseIntensity * (tex2Dlod( _Noise, float4( uv_Noise, 0, 0.0) ).r*2.0 + -1.0) ) + ( (temp_output_48_0).x * (temp_output_48_0).y ) );
				

				v.vertex.xyz += ( v.ase_normal * BoxValue65 * _BrickHeight );
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
			uniform float _NoiseIntensity;
			uniform sampler2D _Noise;
			uniform float4 _Noise_ST;
			uniform float2 _PatternSize;
			uniform float _Slope;
			uniform float _BrickTiling;
			uniform float _BrickHeight;
			uniform sampler2D _InnerAlbedo;
			uniform float4 _InnerAlbedo_ST;
			uniform sampler2D _BrickAlbedo;
			uniform float4 _BrickAlbedo_ST;
			CBUFFER_END
			
			
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature EDITOR_VISUALIZATION


            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
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
				float2 uv_Noise = v.ase_texcoord * _Noise_ST.xy + _Noise_ST.zw;
				float2 ScaledSize42 = ( float2( 0.5,0.5 ) - ( _PatternSize * 0.5 ) );
				float2 temp_output_6_0 = ( _BrickTiling * v.ase_texcoord.xy );
				float temp_output_10_0 = (temp_output_6_0).y;
				float2 appendResult20 = (float2(( ( step( 1.0 , fmod( temp_output_10_0 , 2.0 ) ) * 0.5 ) + (temp_output_6_0).x ) , temp_output_10_0));
				float2 BrickTile19 = frac( appendResult20 );
				float2 smoothstepResult29 = smoothstep( ScaledSize42 , ( ScaledSize42 + _Slope ) , BrickTile19);
				float2 smoothstepResult32 = smoothstep( ScaledSize42 , ( ScaledSize42 + _Slope ) , ( 1.0 - BrickTile19 ));
				float2 temp_output_48_0 = ( smoothstepResult29 * smoothstepResult32 );
				float BoxValue65 = ( ( _NoiseIntensity * (tex2Dlod( _Noise, float4( uv_Noise, 0, 0.0) ).r*2.0 + -1.0) ) + ( (temp_output_48_0).x * (temp_output_48_0).y ) );
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;

				v.vertex.xyz += ( v.ase_normal * BoxValue65 * _BrickHeight );
				v.ase_normal =  v.ase_normal ;
				
                o.clipPos = MetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST);
        	    return o;
            }

            half4 frag(VertexOutput IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

           		float2 uv_InnerAlbedo = IN.ase_texcoord.xy * _InnerAlbedo_ST.xy + _InnerAlbedo_ST.zw;
           		float2 uv_BrickAlbedo = IN.ase_texcoord.xy * _BrickAlbedo_ST.xy + _BrickAlbedo_ST.zw;
           		float2 uv_Noise = IN.ase_texcoord.xy * _Noise_ST.xy + _Noise_ST.zw;
           		float2 ScaledSize42 = ( float2( 0.5,0.5 ) - ( _PatternSize * 0.5 ) );
           		float2 temp_output_6_0 = ( _BrickTiling * IN.ase_texcoord.xy );
           		float temp_output_10_0 = (temp_output_6_0).y;
           		float2 appendResult20 = (float2(( ( step( 1.0 , fmod( temp_output_10_0 , 2.0 ) ) * 0.5 ) + (temp_output_6_0).x ) , temp_output_10_0));
           		float2 BrickTile19 = frac( appendResult20 );
           		float2 smoothstepResult29 = smoothstep( ScaledSize42 , ( ScaledSize42 + _Slope ) , BrickTile19);
           		float2 smoothstepResult32 = smoothstep( ScaledSize42 , ( ScaledSize42 + _Slope ) , ( 1.0 - BrickTile19 ));
           		float2 temp_output_48_0 = ( smoothstepResult29 * smoothstepResult32 );
           		float BoxValue65 = ( ( _NoiseIntensity * (tex2D( _Noise, uv_Noise ).r*2.0 + -1.0) ) + ( (temp_output_48_0).x * (temp_output_48_0).y ) );
           		float4 lerpResult52 = lerp( tex2D( _InnerAlbedo, uv_InnerAlbedo ) , tex2D( _BrickAlbedo, uv_BrickAlbedo ) , BoxValue65);
           		
				
		        float3 Albedo = lerpResult52.rgb;
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
-1913;7;1429;1044;-81.74239;40.03043;1.3;True;True
Node;AmplifyShaderEditor.CommentaryNode;18;-1277.912,-1051.487;Float;False;2077.928;478.4274;;15;19;17;5;2;20;22;16;15;14;11;12;6;7;10;9;Brick Tile;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;5;-1216,-864;Float;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;2;-1168,-944;Float;False;Property;_BrickTiling;Brick Tiling;9;0;Create;True;0;0;False;0;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-996.1118,-923.3873;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;10;-788.5117,-955.4869;Float;False;False;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-667.012,-796.4873;Float;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FmodOpNode;7;-513.6121,-826.4878;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-512,-912;Float;False;Constant;_Float1;Float 1;3;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;11;-352,-864;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;16;-561.9666,-662.2005;Float;False;True;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;63;-1908.419,-250.2862;Float;False;1962.68;1056.631;;27;65;72;76;77;49;74;51;50;75;1;48;32;29;33;30;47;24;42;36;45;43;64;27;25;28;3;83;Box Pattern;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleNode;14;-224,-864;Float;False;0.5;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;3;-1855.674,19.04404;Float;False;Property;_PatternSize;Pattern Size;7;0;Create;True;0;0;False;0;0,0;0.9,0.9;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-48,-864;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;22;-116.6251,-954.1458;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;20;165,-904;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleNode;28;-1653.419,16.81863;Float;False;0.5;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;25;-1858.419,-135.1814;Float;False;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;False;0;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;27;-1520,-80;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;17;304,-896;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;432,-912;Float;False;BrickTile;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-1352.028,-90.58098;Float;False;ScaledSize;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-1840,533.6351;Float;False;19;BrickTile;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1879,440;Float;False;Property;_Slope;Slope;5;0;Create;True;0;0;False;0;0.4;0.025;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-1840,629.635;Float;False;42;ScaledSize;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-1833.669,253.0998;Float;False;42;ScaledSize;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-1584,677.635;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-1600,336;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-1552,208;Float;False;19;BrickTile;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;47;-1643.61,533.3613;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;32;-1440,533.6351;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;29;-1329.73,229.8195;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-977.0161,177.672;Float;False;Constant;_Float5;Float 5;9;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-978.6541,257.3488;Float;False;Constant;_Float2;Float 2;11;0;Create;True;0;0;False;0;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-1094,423;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-1070.584,-19.63151;Float;True;Property;_Noise;Noise;6;0;Create;True;0;0;False;0;None;bdbe94d7623ec3940947b62544306f1c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;74;-765.0161,71.67205;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;51;-896,480;Float;False;False;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;50;-896,384;Float;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-767,-47;Float;False;Property;_NoiseIntensity;Noise Intensity;8;0;Create;True;0;0;False;0;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-656,432;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-448,16;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;-288,144;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-160,144;Float;False;BoxValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;82;780.6656,980.0601;Float;False;501.262;452.3835;;4;62;67;61;60;Vertex Offset based on pattern;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;81;187.544,-171.2445;Float;False;820.8564;1060.148;;9;66;54;53;52;55;58;68;57;56;Albedo+Normal based on pattern;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;62;833.8668,1317.444;Float;False;Property;_BrickHeight;Brick Height;10;0;Create;True;0;0;False;0;0;0.16;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;54;292.0771,-121.2445;Float;True;Property;_InnerAlbedo;Inner Albedo;11;0;Create;True;0;0;False;0;None;00d034bb5072d8043a98b8a4aae5a40d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;66;445.0507,284.506;Float;False;65;BoxValue;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;61;864.0197,1030.06;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;53;290.7773,72.35526;Float;True;Property;_BrickAlbedo;Brick Albedo;13;0;Create;True;0;0;False;0;None;b297077dae62c1944ba14cad801cddf5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;67;830.6656,1216.765;Float;False;65;BoxValue;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;58;744.4005,460.8596;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;52;657.601,15.88497;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;350.5562,773.9034;Float;False;65;BoxValue;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;57;237.544,577.1262;Float;True;Property;_BrickNormal;Brick Normal;14;0;Create;True;0;0;False;0;None;0bebe40e9ebbecc48b8e9cfea982da7e;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;1112.928,1125.61;Float;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;56;243.544,385.1258;Float;True;Property;_InnerNormal;Inner Normal;12;0;Create;True;0;0;False;0;None;7ddcba51d9fc0894d98b4ba77fbdfbd7;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;55;555.4005,467.8596;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;85;1223.489,321.9786;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;1;ShadowCaster;0;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;86;1223.489,321.9786;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;2;DepthOnly;0;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;84;1223.489,321.9786;Float;False;True;2;Float;ASEMaterialInspector;0;2;ASESampleShaders/ProceduralWall;1976390536c6c564abb90fe41f6ee334;0;0;ProcuduralWall;11;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;;0;0;Standard;1;_FinalColorxAlpha;0;11;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;9;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT3;0,0,0;False;10;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;87;1223.489,321.9786;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;3;Meta;0;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;;0;0;Standard;0;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;0
WireConnection;6;0;2;0
WireConnection;6;1;5;0
WireConnection;10;0;6;0
WireConnection;7;0;10;0
WireConnection;7;1;9;0
WireConnection;11;0;12;0
WireConnection;11;1;7;0
WireConnection;16;0;6;0
WireConnection;14;0;11;0
WireConnection;15;0;14;0
WireConnection;15;1;16;0
WireConnection;22;0;10;0
WireConnection;20;0;15;0
WireConnection;20;1;22;0
WireConnection;28;0;3;0
WireConnection;27;0;25;0
WireConnection;27;1;28;0
WireConnection;17;0;20;0
WireConnection;19;0;17;0
WireConnection;42;0;27;0
WireConnection;33;0;45;0
WireConnection;33;1;43;0
WireConnection;30;0;64;0
WireConnection;30;1;43;0
WireConnection;47;0;36;0
WireConnection;32;0;47;0
WireConnection;32;1;45;0
WireConnection;32;2;33;0
WireConnection;29;0;24;0
WireConnection;29;1;64;0
WireConnection;29;2;30;0
WireConnection;48;0;29;0
WireConnection;48;1;32;0
WireConnection;74;0;1;1
WireConnection;74;1;75;0
WireConnection;74;2;83;0
WireConnection;51;0;48;0
WireConnection;50;0;48;0
WireConnection;49;0;50;0
WireConnection;49;1;51;0
WireConnection;76;0;77;0
WireConnection;76;1;74;0
WireConnection;72;0;76;0
WireConnection;72;1;49;0
WireConnection;65;0;72;0
WireConnection;58;0;55;0
WireConnection;52;0;54;0
WireConnection;52;1;53;0
WireConnection;52;2;66;0
WireConnection;60;0;61;0
WireConnection;60;1;67;0
WireConnection;60;2;62;0
WireConnection;55;0;56;0
WireConnection;55;1;57;0
WireConnection;55;2;68;0
WireConnection;84;0;52;0
WireConnection;84;1;58;0
WireConnection;84;8;60;0
ASEEND*/
//CHKSM=01FC97981ACAA0FECF996247904ACB8123FFB428