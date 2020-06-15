using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.InteropServices;

using Unity.Mathematics;
using static Unity.Mathematics.math;

public class QuaternionTest : MonoBehaviour
{
    public struct Particle
    {
        public float3 position;
        public float4 rotation;
        public float4 rotationAxisY;
    }

    [SerializeField]
    float3 _targetPosition = float3(0.0f, 0.001f, 0.0f);

    [SerializeField]
    ComputeShader _kernelCS;

    ComputeBuffer _particleBuffer;
    
    Renderer _renderer;

    MaterialPropertyBlock _mbp;

    
    void Start()
    {
        _particleBuffer = new ComputeBuffer(1, Marshal.SizeOf(typeof(Particle)));

        var particleArr = new Particle[1];
        particleArr[0].position      = float3(0, 0, 0);
        particleArr[0].rotation      = float4(0, 0, 0, 1);
        particleArr[0].rotationAxisY = float4(0, 0, 0, 1);
        _particleBuffer.SetData(particleArr);
        particleArr = null;

        _renderer = GetComponent<Renderer>();

        _mbp = new MaterialPropertyBlock();
        
    }

    void Update()
    {

        _kernelCS.SetFloat("_DeltaTime", Time.deltaTime);
        _kernelCS.SetFloat("_Time", Time.time);
        _kernelCS.SetVector("_TargetPosition", (Vector3)_targetPosition);
        _kernelCS.SetBuffer(0, "_ParticleBufferRW", _particleBuffer);

        _kernelCS.Dispatch(0, 1, 1, 1);

        _mbp.SetBuffer("_ParticleBuffer", _particleBuffer);
        _renderer.SetPropertyBlock(_mbp);
    
        if (Input.GetKeyUp("r"))
        {
            _targetPosition = UnityEngine.Random.insideUnitSphere * 4.0f;
        }
    }

    void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawSphere(_targetPosition, 0.2f);

        Gizmos.color = Color.yellow;
        Gizmos.DrawLine(float3(0, 0, 0), _targetPosition);
    }

    void OnDestroy()
    {
        if (_particleBuffer != null)
        {
            _particleBuffer.Release();
            _particleBuffer = null;
        }

        if (_mbp != null)
        {
            _mbp = null;
        }
    }
}
