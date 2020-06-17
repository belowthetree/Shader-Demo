using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class RenderShadow : MonoBehaviour
{
    public Material mat;
    public RenderTexture target;
    public Transform transform;

    void Start(){
    }
    
    void OnRenderImage(RenderTexture source, RenderTexture destination){
        if (target == null)
            Graphics.Blit(source, destination, mat);
        else
            Graphics.Blit(source, destination, mat);
    }
    void Update(){

    }
}
