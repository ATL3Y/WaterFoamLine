using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent ( typeof ( AudioSource ) )]
[RequireComponent ( typeof ( Light ) )]
public class ClipInput : MonoBehaviour
{
    public float ClipLoudness01;
    private AudioSource aud;
    private Light l;
    private Material mat;
    private int sampleWindow = 128;

    private void InitClip ( )
    {
        aud = GetComponent<AudioSource> ( );
        //aud.playOnAwake = false;
        //aud.loop = false;
        l = GetComponent<Light> ( );
        mat = GetComponent<MeshRenderer> ( ).material;
        mat.globalIlluminationFlags = MaterialGlobalIlluminationFlags.RealtimeEmissive;

        colEmiss = new Color ( 1.0f, 1.0f, 1.0f, 1.0f );
    }

    private void OnEnable ( )
    {
        InitClip ( );
    }

    private float ClipLevelMax ( )
    {
        float levelMax = 0;
        float[] waveData = new float[sampleWindow];
        int clipPosition = aud.timeSamples;  // Does this update per clip? 
        aud.clip.GetData ( waveData, clipPosition );

        // Get a peak on the last 128 samples.
        for ( int i = 0; i < sampleWindow; i++ )
        {
            float wavePeak = waveData[i] * waveData[i];
            if ( levelMax < wavePeak )
            {
                levelMax = wavePeak;
            }
        }
        // Debug.Log ( levelMax );
        return levelMax;
    }

    private float velocity = 0.0f;
    private float minLoudness = 1.0f;
    private float maxLoudness = 0.0f;
    private float sampleTimer = 2.0f;
    private Color colEmiss;
    private void Update ( )
    {
        if ( !aud.isPlaying )
        {
            ClipLoudness01 = 0.0f;

            /*
            if ( Input.GetKeyDown ( KeyCode.Space ) )
            {
                aud.Play ( );
            }
            */
        }
        else
        {
            // Resample every 2 seconds...
            sampleTimer -= Time.deltaTime;
            if ( sampleTimer <= 0.0f )
            {
                sampleTimer = 2.0f;
                maxLoudness = 1.0f;
                minLoudness = 0.0f;
            }

            float val = 1000.0f * ClipLevelMax ( );

            if ( val < minLoudness )
            {
                minLoudness = val; // 0
            }
            else if ( val > maxLoudness )
            {
                maxLoudness = val; // 1
            }

            val -= minLoudness;
            float range = maxLoudness - minLoudness;

            ClipLoudness01 = Mathf.SmoothDamp ( ClipLoudness01, val / range, ref velocity, 3.0f * Time.deltaTime ); //val / range;
            l.intensity = 3.0f * ClipLoudness01;
            l.range = 2.5f * ClipLoudness01;
            mat.SetColor ( "_EmissionColor", colEmiss * ClipLoudness01 );

        }
    }
}
