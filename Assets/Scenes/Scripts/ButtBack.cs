using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using EasyInputVR.Core;

public class ButtBack : MonoBehaviour
{
    public GameObject capsul;
    public Transform respawnSky;

    void Start()
    {
        capsul = GetComponent<GameObject>();
    }

    void Update()
    {
        
    }

    void localClickStart(ButtonClick button)
    {
        if (EasyInputHelper.isGearVR || Application.isEditor)
        {
            if (button.button == EasyInputConstants.CONTROLLER_BUTTON.Back)
            {
                capsul.transform.position = respawnSky.position;
                capsul.transform.rotation = respawnSky.rotation;
            }                
        }
    }
}
