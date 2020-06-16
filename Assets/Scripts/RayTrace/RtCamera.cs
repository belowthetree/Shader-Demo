using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

// [ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class RtCamera : MonoBehaviour
{
    public ComputeShader rayTrace;
    public Texture SkyboxTexture;
    public Camera _camera;
    public Light directionLight;

    private RenderTexture _target;
    private uint _currentSample = 0;
    private Material _addMaterial;
    public Transform _transform;

    public Vector2 SphereRadius = new Vector2(3.0f, 8.0f);
    public uint SpheresMax = 100;
    public float SpherePlacementRadius = 100.0f;
    private ComputeBuffer _sphereBuffer;

    struct Sphere
    {
        public Vector3 position;
        public float radius;
        public Vector3 albedo;
        public Vector3 specular;
    };

    public bool update = true;
    private void OnRenderImage(RenderTexture source, RenderTexture destination) {
        if (update || _sphereBuffer == null){
            SetUpScene();
            update = false;
        }
        if (_transform.hasChanged || _addMaterial == null || _target == null){
            _currentSample = 0;
            _transform.hasChanged = false;
            RtSetting();
        }
        Graphics.Blit(_target, destination, _addMaterial);
    }

    private void Update(){
        if (Input.GetKey(KeyCode.W)){
            _transform.position += _transform.forward;
        }
        if (Input.GetKey(KeyCode.A)){
            _transform.position -= _transform.right;
        }
        if (Input.GetKey(KeyCode.S)){
            _transform.position -= _transform.forward;
        }
        if (Input.GetKey(KeyCode.D)){
            _transform.position += _transform.right;
        }
        if (Input.GetKey(KeyCode.Space)){
            _transform.position += _transform.up;
        }
        if (Input.GetKey(KeyCode.LeftShift)){
            _transform.position -= _transform.up;
        }
    }

    private void RtSetting() {
        if (_target == null)
            GenTex(ref _target);
        if (_addMaterial == null)
            _addMaterial = new Material(Shader.Find("Hidden/AddShader"));
        _addMaterial.SetFloat("_Sample", _currentSample);
        _currentSample++;

        rayTrace.SetTexture(0, "Result", _target);
        rayTrace.SetMatrix("_CameraToWorld", _camera.cameraToWorldMatrix);
        rayTrace.SetMatrix("_CameraInverseProjection", _camera.projectionMatrix.inverse);
        rayTrace.SetTexture(0, "_SkyboxTexture", SkyboxTexture);
        rayTrace.SetBuffer(0, "_Spheres", _sphereBuffer);
        var l = directionLight.transform.forward;
        rayTrace.SetVector("_DirectionalLight", new Vector4(l.x, l.y, l.z, directionLight.intensity));
        
        int threadGroupsX = Mathf.CeilToInt(Screen.width / 8.0f);
        int threadGroupsY = Mathf.CeilToInt(Screen.height / 8.0f);
        rayTrace.Dispatch(0, threadGroupsX, threadGroupsY, 1);
    }

    private void GenTex(ref RenderTexture tex) {
        if (tex != null)
            tex.Release();
        tex = new RenderTexture(Screen.width, Screen.height, 0,
            RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
        tex.enableRandomWrite = true;
        tex.Create();
    }

    private void SetUpScene()
    {
        List<Sphere> spheres = new List<Sphere>();
        // Add a number of random spheres
        for (int i = 0; i < SpheresMax; i++)
        {
            Sphere sphere = new Sphere();
            // Radius and radius
            sphere.radius = SphereRadius.x + Random.value * (SphereRadius.y - SphereRadius.x);
            Vector2 randomPos = Random.insideUnitCircle * SpherePlacementRadius;
            sphere.position = new Vector3(randomPos.x, sphere.radius, randomPos.y);
            // Reject spheres that are intersecting others
            foreach (Sphere other in spheres)
            {
                float minDist = sphere.radius + other.radius;
                if (Vector3.SqrMagnitude(sphere.position - other.position) < minDist * minDist)
                    goto SkipSphere;
            }
            // Albedo and specular color
            Color color = Random.ColorHSV();
            bool metal = Random.value < 0.5f;
            sphere.albedo = metal ? Vector3.zero : new Vector3(color.r, color.g, color.b);
            sphere.specular = metal ? new Vector3(color.r, color.g, color.b) : Vector3.one * 0.04f;
            // Add the sphere to the list
            spheres.Add(sphere);
        SkipSphere:
            continue;
        }
        if (_sphereBuffer != null)
            _sphereBuffer.Release();
        // Assign to compute buffer
        _sphereBuffer = new ComputeBuffer(spheres.Count, 40);
        _sphereBuffer.SetData(spheres);
    }
}
