using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VoiceParticles : MonoBehaviour
{
    [SerializeField]
    ParticleSystem sys;
    [SerializeField]
    Transform head;

    float cooldown = 0f;
    // Update is called once per frame
    void Update ( )
    {
        
        cooldown -= Time.deltaTime;
        if ( cooldown < 0f )
        {
            float val = 1000.0f * MicInput.MicLoudness;
            val = val * val * val;
            // print ( val );
            if ( val > 1.0f )
            {
                transform.position = head.position;
                transform.rotation = head.rotation;
                sys.Play ( );
                cooldown = 1.0f;
            }
        }
        else
        {
            sys.Stop ( );
        }

    }
}
