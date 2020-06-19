using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CameraRender : MonoBehaviour
{
    int film_offx = Shader.PropertyToID("_RandOffsetX");
    int film_offy = Shader.PropertyToID("_RandOffsetY");
    int time_scale = Shader.PropertyToID("_TimeScale");
    public enum EEffectType
    {
        film,
        edgeDetect,
        relief,
    }
    public EEffectType eEffectType;
    public Material filmMat;
    public Material edgeDetectMat;
    public Material reliefMat;
    [Range(0.01f,5f)]
    public float RandInterval = 1;
    public float TimeScale = 1;
    float intervalTime = 0;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }
    private void OnValidate()
    {
        switch (eEffectType)
        {
            case EEffectType.film:
                filmMat.SetFloat(time_scale, TimeScale);
                break;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        RenderTexture src0 = RenderTexture.GetTemporary(source.width, source.height);
        Material mat = GetMat();
        SetMatProperty();
        Graphics.Blit(source, src0, mat, 0);
        Graphics.Blit(src0, destination);

        RenderTexture.ReleaseTemporary(src0);

    }

    Material GetMat()
    {
        switch (eEffectType)
        {
            case EEffectType.edgeDetect:
                return edgeDetectMat;
            case EEffectType.film:
                return filmMat;
            case EEffectType.relief:
                return reliefMat;
        }
        return edgeDetectMat;
    }

    void SetMatProperty()
    {
        switch (eEffectType)
        {
            case EEffectType.film:
                intervalTime += Time.deltaTime;
                if (intervalTime > RandInterval)
                {
                    filmMat.SetFloat(film_offx, Random.Range(-1f, 1f));
                    filmMat.SetFloat(film_offy, Random.Range(-1f, 1f));
                    intervalTime = 0;
                }
                break;
        }
    }
}