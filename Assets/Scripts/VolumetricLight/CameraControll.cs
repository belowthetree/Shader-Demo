using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class CameraControll : MonoBehaviour
{
    public Camera lightCamera;
    public Material material;
    public float theta;
    public RenderTexture _target;
    
    void Start(){
        if (_target != null)
            _target.Release();
        _target = RenderTexture.GetTemporary(lightCamera.pixelWidth, lightCamera.pixelHeight, 16, RenderTextureFormat.ARGB32);
        _target.wrapMode = TextureWrapMode.Clamp;
        lightCamera.targetTexture = _target;
        lightCamera.GetComponent<RenderShadow>().target = _target;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination){
        GetLightProjectMatrix(material);
        material.SetTexture("_ShadowMap", _target);
        material.SetFloat("theta", theta);
        Graphics.Blit(source, destination, material);
    }
    
    //perspective matrix
	void  GetLightProjectMatrix(Material mat)
	{
		Matrix4x4 worldToView = lightCamera.worldToCameraMatrix;
		Matrix4x4 projection  = GL.GetGPUProjectionMatrix(lightCamera.projectionMatrix, false);
		Matrix4x4 lightProjecionMatrix = projection * worldToView;
		mat.SetMatrix("_LightProjection", lightProjecionMatrix);
	}
}
