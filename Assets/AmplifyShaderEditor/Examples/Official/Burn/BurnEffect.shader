// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASESampleShaders/BurnEffect"
{
    Properties
    {
		_AlbedoMix("Albedo Mix", Range( 0 , 1)) = 0.5
		_CharcoalMix("Charcoal Mix", Range( 0 , 1)) = 1
		EmberColorTint("Ember Color Tint", Color) = (0.9926471,0.6777384,0,1)
		Albedo("Albedo", 2D) = "white" {}
		Normals("Normals", 2D) = "bump" {}
		BaseEmber("Base Ember", Range( 0 , 1)) = 0
		GlowEmissionMultiplier("Glow Emission Multiplier", Range( 0 , 30)) = 1
		GlowColorIntensity("Glow Color Intensity", Range( 0 , 10)) = 0
		_BurnOffset("Burn Offset", Range( 0 , 5)) = 1
		_CharcoalNormalTile("Charcoal Normal Tile", Range( 2 , 5)) = 5
		_BurnTilling("Burn Tilling", Range( 0.1 , 1)) = 1
		GlowBaseFrequency("Glow Base Frequency", Range( 0 , 5)) = 1.1
		GlowOverride("Glow Override", Range( 0 , 10)) = 1
		Masks("Masks", 2D) = "white" {}
		BurntTileNormals("Burnt Tile Normals", 2D) = "white" {}
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

        	Name "Base"
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
			uniform sampler2D Albedo;
			uniform half _AlbedoMix;
			uniform half _CharcoalMix;
			uniform sampler2D Masks;
			uniform half _BurnOffset;
			uniform half _BurnTilling;
			uniform sampler2D BurntTileNormals;
			uniform half _CharcoalNormalTile;
			uniform half BaseEmber;
			uniform sampler2D Normals;
			uniform half4 EmberColorTint;
			uniform half GlowColorIntensity;
			uniform half GlowBaseFrequency;
			uniform half GlowOverride;
			uniform half GlowEmissionMultiplier;
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

				o.ase_texcoord7.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				v.vertex.xyz +=  float3( 0, 0, 0 ) ;
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
    
				float2 uv180 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				half4 tex2DNode80 = tex2D( Albedo, uv180 );
				half4 temp_cast_0 = (0.0).xxxx;
				float2 panner9 = ( _BurnOffset * float2( 1,0.5 ) + ( uv180 * _BurnTilling ));
				half4 tex2DNode98 = tex2D( Masks, panner9 );
				float temp_output_19_0 = ( _CharcoalMix + tex2DNode98.r );
				float4 lerpResult28 = lerp( ( tex2DNode80 * _AlbedoMix ) , temp_cast_0 , temp_output_19_0);
				float2 uv179 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				half4 tex2DNode83 = tex2D( BurntTileNormals, ( uv179 * _CharcoalNormalTile ) );
				float4 lerpResult148 = lerp( ( half4(0.718,0.0627451,0,1) * ( tex2DNode83.a * 2.95 ) ) , ( half4(0.647,0.06297875,0,1) * ( tex2DNode83.a * 4.2 ) ) , tex2DNode98.g);
				float4 lerpResult152 = lerp( lerpResult28 , ( ( lerpResult148 * tex2DNode98.r ) * BaseEmber ) , ( tex2DNode98.r * 1.0 ));
				
				float4 appendResult182 = (half4(1.0 , tex2DNode83.g , 0.0 , tex2DNode83.r));
				float3 lerpResult103 = lerp( UnpackNormalmapRGorAG( tex2D( Normals, uv179 ), 1.0f ) , UnpackNormalmapRGorAG( appendResult182, 1.0 ) , temp_output_19_0);
				
				half4 temp_cast_2 = (0.0).xxxx;
				half4 temp_cast_3 = (100.0).xxxx;
				float4 clampResult176 = clamp( ( ( tex2DNode98.r * ( ( ( ( EmberColorTint * GlowColorIntensity ) * ( ( sin( ( _Time.y * GlowBaseFrequency ) ) * 0.5 ) + ( GlowOverride * ( tex2DNode98.r * tex2DNode83.a ) ) ) ) * tex2DNode98.g ) * tex2DNode83.a ) ) * GlowEmissionMultiplier ) , temp_cast_2 , temp_cast_3 );
				
				
		        float3 Albedo = lerpResult152.rgb;
				float3 Normal = lerpResult103;
				float3 Emission = clampResult176.rgb;
				float3 Specular = float3(0.5, 0.5, 0.5);
				float Metallic = 0;
				float Smoothness = tex2DNode80.a;
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

				

				v.vertex.xyz +=  float3(0,0,0) ;
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

				

				v.vertex.xyz +=  float3(0,0,0) ;
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
			uniform sampler2D Albedo;
			uniform half _AlbedoMix;
			uniform half _CharcoalMix;
			uniform sampler2D Masks;
			uniform half _BurnOffset;
			uniform half _BurnTilling;
			uniform sampler2D BurntTileNormals;
			uniform half _CharcoalNormalTile;
			uniform half BaseEmber;
			uniform half4 EmberColorTint;
			uniform half GlowColorIntensity;
			uniform half GlowBaseFrequency;
			uniform half GlowOverride;
			uniform half GlowEmissionMultiplier;
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
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;

				v.vertex.xyz +=  float3(0,0,0) ;
				v.ase_normal =  v.ase_normal ;
				
                o.clipPos = MetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST);
        	    return o;
            }

            half4 frag(VertexOutput IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

           		float2 uv180 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
           		half4 tex2DNode80 = tex2D( Albedo, uv180 );
           		half4 temp_cast_0 = (0.0).xxxx;
           		float2 panner9 = ( _BurnOffset * float2( 1,0.5 ) + ( uv180 * _BurnTilling ));
           		half4 tex2DNode98 = tex2D( Masks, panner9 );
           		float temp_output_19_0 = ( _CharcoalMix + tex2DNode98.r );
           		float4 lerpResult28 = lerp( ( tex2DNode80 * _AlbedoMix ) , temp_cast_0 , temp_output_19_0);
           		float2 uv179 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
           		half4 tex2DNode83 = tex2D( BurntTileNormals, ( uv179 * _CharcoalNormalTile ) );
           		float4 lerpResult148 = lerp( ( half4(0.718,0.0627451,0,1) * ( tex2DNode83.a * 2.95 ) ) , ( half4(0.647,0.06297875,0,1) * ( tex2DNode83.a * 4.2 ) ) , tex2DNode98.g);
           		float4 lerpResult152 = lerp( lerpResult28 , ( ( lerpResult148 * tex2DNode98.r ) * BaseEmber ) , ( tex2DNode98.r * 1.0 ));
           		
           		half4 temp_cast_2 = (0.0).xxxx;
           		half4 temp_cast_3 = (100.0).xxxx;
           		float4 clampResult176 = clamp( ( ( tex2DNode98.r * ( ( ( ( EmberColorTint * GlowColorIntensity ) * ( ( sin( ( _Time.y * GlowBaseFrequency ) ) * 0.5 ) + ( GlowOverride * ( tex2DNode98.r * tex2DNode83.a ) ) ) ) * tex2DNode98.g ) * tex2DNode83.a ) ) * GlowEmissionMultiplier ) , temp_cast_2 , temp_cast_3 );
           		
				
		        float3 Albedo = lerpResult152.rgb;
				float3 Emission = clampResult176.rgb;
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
-1919;1;1918;1056;1453.455;132.7401;1.514845;True;True
Node;AmplifyShaderEditor.CommentaryNode;128;-3113.25,-277.6554;Float;False;1648.54;574.2015;;7;7;9;11;10;98;180;129;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;39;-2354.221,1634.534;Float;False;1523.056;586.484;Base + Burnt Detail Mix (1 Free Alpha channels if needed);9;103;181;182;6;5;179;82;40;183;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;180;-3032.306,-240.7004;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;11;-3060.807,-39.78358;Float;False;Property;_BurnTilling;Burn Tilling;10;0;Create;True;0;0;False;0;1;0.179;0.1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-3061.854,59.54606;Float;False;Property;_BurnOffset;Burn Offset;8;0;Create;True;0;0;False;0;1;0.22;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;130;-2566.58,462.9727;Float;False;2529.991;765.4811;Emission;18;157;158;69;66;95;68;67;76;73;77;127;65;70;106;101;170;174;169;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-2680.848,-125.3553;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-2308.22,1995.127;Float;False;Property;_CharcoalNormalTile;Charcoal Normal Tile;9;0;Create;True;0;0;False;0;5;2;2;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;179;-2297.001,1722.1;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;40;-1862.12,1886.328;Float;False;343.3401;246.79;Emission in Alpha;1;83;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-2032,1872;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-2501.525,1037.474;Float;False;Property;GlowBaseFrequency;Glow Base Frequency;11;0;Create;True;0;0;False;0;1.1;2.35;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;67;-2487.243,814.3365;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;9;-2436.848,-67.1541;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0.5;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-2214.131,864.2569;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;98;-2187.974,90.68339;Float;True;Property;Masks;Masks;13;0;Create;True;0;0;False;0;None;e24b2c680edaa90458d31f11544d79ca;True;1;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;1,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;83;-1837.837,1936.235;Float;True;Property;BurntTileNormals;Burnt Tile Normals;14;0;Create;True;0;0;False;0;None;e9742c575b8f4644fb9379e7347ff62e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;1,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;66;-2005.042,836.0363;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-2503.727,1130.798;Float;False;Property;GlowOverride;Glow Override;12;0;Create;True;0;0;False;0;1;1.07;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-2048.016,1006.15;Float;False;Constant;GlowDuration;Glow Duration;-1;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;171;-2059.027,1470.798;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;-1863.427,1078.999;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-1859.748,866.4651;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-2516.58,713.7126;Float;False;Property;GlowColorIntensity;Glow Color Intensity;7;0;Create;True;0;0;False;0;0;0.56;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;73;-2500.298,512.9727;Float;False;Property;EmberColorTint;Ember Color Tint;2;0;Create;True;0;0;False;0;0.9926471,0.6777384,0,1;0.966,0.1062519,0.004325263,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;138;-1244.786,362.2247;Float;False;Constant;R2;R2;-1;0;Create;True;0;0;False;0;4.2;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-1833.5,705.4734;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-1201.686,-84.4754;Float;False;Constant;R2144;R2 144;-1;0;Create;True;0;0;False;0;2.95;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;174;-1695.621,992.7978;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;-877.9863,266.6246;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;134;-1253.789,180.1245;Float;False;Constant;ColorNode39134;ColorNode 39 134;-1;0;Create;True;0;0;False;0;0.647,0.06297875,0,1;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;-864.0865,-85.57518;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-1650.418,755.3741;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;147;-1134.788,-277.6757;Float;False;Constant;ColorNode39134147;ColorNode39134 147;-1;0;Create;True;0;0;False;0;0.718,0.0627451,0,1;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;38;-1752.147,-1032.491;Float;False;1183.903;527.3994;Albedo - Smoothness in Alpha;5;35;27;34;28;80;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-718.0855,-186.0759;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;-1374.632,659.5688;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;129;-2023.204,-221.9194;Float;False;471.6918;296.3271;Mix Base Albedo;2;13;19;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-735.1851,46.52425;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;80;-1643.756,-782.4553;Float;True;Property;Albedo;Albedo;3;0;Create;True;0;0;False;0;None;7130c16fd8005b546b111d341310a9a4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;1,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;148;-532.6986,-105.8688;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2012.303,-170.8193;Float;False;Property;_CharcoalMix;Charcoal Mix;1;0;Create;True;0;0;False;0;1;0.713;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1666.103,-951.4903;Float;False;Property;_AlbedoMix;Albedo Mix;0;0;Create;True;0;0;False;0;0.5;0.356;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;-1147.638,615.7524;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;158;-922.8376,723.2053;Float;False;Property;GlowEmissionMultiplier;Glow Emission Multiplier;6;0;Create;True;0;0;False;0;1;12.6;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-348.4115,-25.67536;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1279.204,-773.5922;Float;False;Constant;_RangedFloatNode27;_RangedFloatNode27;-1;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;-952.7081,532.5618;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-1726.307,-47.39226;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-535.9109,125.925;Float;False;Property;BaseEmber;Base Ember;5;0;Create;True;0;0;False;0;0;0.133;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-1277.102,-982.4909;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;156;-182.4112,109.8244;Float;False;Constant;RangedFloatNode156;RangedFloatNode 156;-1;0;Create;True;0;0;False;0;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;41.58921,-45.27597;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;177;-204.6184,257.1976;Float;False;Constant;RangedFloatNode177;RangedFloatNode 177;-1;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;157;-597.8378,569.7058;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;178;30.78172,469.7978;Float;False;Constant;RangedFloatNode178;RangedFloatNode 178;-1;0;Create;True;0;0;False;0;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-118.0104,-148.7752;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;28;-970.9127,-675.8198;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;182;-1500.6,1970.726;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;176;257.5815,221.0976;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;152;247.1904,-253.5751;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;103;-1004.304,1816.428;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;82;-1360.313,1695.685;Float;True;Property;Normals;Normals;4;0;Create;True;0;0;False;0;None;11f03d9db1a617e40b7ece71f0a84f6f;True;2;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;1,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;183;-1653.1,1805.106;Float;False;Constant;_Float0;Float 0;15;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;181;-1341.6,1914.726;Float;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;186;954.3982,76.31933;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;2;DepthOnly;0;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;184;954.3982,76.31933;Float;False;True;2;Float;ASEMaterialInspector;0;2;ASESampleShaders/BurnEffect;1976390536c6c564abb90fe41f6ee334;0;0;Base;11;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;;0;0;Standard;1;_FinalColorxAlpha;0;11;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;9;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT3;0,0,0;False;10;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;185;954.3982,76.31933;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;1;ShadowCaster;0;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;187;954.3982,76.31933;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;3;Meta;0;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;;0;0;Standard;0;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;0
WireConnection;7;0;180;0
WireConnection;7;1;11;0
WireConnection;5;0;179;0
WireConnection;5;1;6;0
WireConnection;9;0;7;0
WireConnection;9;1;10;0
WireConnection;68;0;67;2
WireConnection;68;1;76;0
WireConnection;98;1;9;0
WireConnection;83;1;5;0
WireConnection;66;0;68;0
WireConnection;171;0;98;1
WireConnection;171;1;83;4
WireConnection;170;0;169;0
WireConnection;170;1;171;0
WireConnection;69;0;66;0
WireConnection;69;1;95;0
WireConnection;65;0;73;0
WireConnection;65;1;77;0
WireConnection;174;0;69;0
WireConnection;174;1;170;0
WireConnection;137;0;83;4
WireConnection;137;1;138;0
WireConnection;145;0;83;4
WireConnection;145;1;144;0
WireConnection;70;0;65;0
WireConnection;70;1;174;0
WireConnection;146;0;147;0
WireConnection;146;1;145;0
WireConnection;101;0;70;0
WireConnection;101;1;98;2
WireConnection;136;0;134;0
WireConnection;136;1;137;0
WireConnection;80;1;180;0
WireConnection;148;0;146;0
WireConnection;148;1;136;0
WireConnection;148;2;98;2
WireConnection;106;0;101;0
WireConnection;106;1;83;4
WireConnection;149;0;148;0
WireConnection;149;1;98;1
WireConnection;127;0;98;1
WireConnection;127;1;106;0
WireConnection;19;0;13;0
WireConnection;19;1;98;1
WireConnection;34;0;80;0
WireConnection;34;1;35;0
WireConnection;154;0;98;1
WireConnection;154;1;156;0
WireConnection;157;0;127;0
WireConnection;157;1;158;0
WireConnection;151;0;149;0
WireConnection;151;1;150;0
WireConnection;28;0;34;0
WireConnection;28;1;27;0
WireConnection;28;2;19;0
WireConnection;182;0;183;0
WireConnection;182;1;83;2
WireConnection;182;3;83;1
WireConnection;176;0;157;0
WireConnection;176;1;177;0
WireConnection;176;2;178;0
WireConnection;152;0;28;0
WireConnection;152;1;151;0
WireConnection;152;2;154;0
WireConnection;103;0;82;0
WireConnection;103;1;181;0
WireConnection;103;2;19;0
WireConnection;82;1;179;0
WireConnection;181;0;182;0
WireConnection;184;0;152;0
WireConnection;184;1;103;0
WireConnection;184;2;176;0
WireConnection;184;4;80;4
ASEEND*/
//CHKSM=AD2AA8BCC7107BDFA52D6201B26A2D15E0800FFB