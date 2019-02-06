using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SWS;
using EasyInputVR.Misc;
using UnityEngine.UI;
using EasyInputVR.StandardControllers;

public class TriggerStopFly : MonoBehaviour
{
    public GameObject capsul;
    private Image fadeCam;
    private Rigidbody rigCapsul;
    private splineMove spmCapsul;
    private pointerSwitch laserCapsul;
    private StandardLaserPointer standartLaser;


    private void Awake()
    {
        rigCapsul = capsul.GetComponent<Rigidbody>();
        spmCapsul = capsul.GetComponent<splineMove>();
        laserCapsul = capsul.GetComponent<pointerSwitch>();
        standartLaser = laserCapsul.laserPointer.GetComponent<StandardLaserPointer>();
       
    }

    void Start()
    {
       
    }

    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject == capsul)
        {
            for (int i = 0; i < CTRLtriggersPoints.point.Length; i++)
            {
                if (CTRLtriggersPoints.point[i].activeSelf)
                {

                    //CTRL_TeleportOnOf.teleportOnOf.enabled = true;

                    CTRL_FadeCam.fadeCam.duration = 3f;
                    CTRL_FadeCam.fadeCam.DORestartById("fadeCam");
                    CTRL_FadeCam.fadeCam.DOPlayById("fadeCam");

                    rigCapsul.isKinematic = true;
                    rigCapsul.useGravity = false;

                    RenderSettings.skybox = CTRL_SkyMat.mSkyGround;

                    laserCapsul.laserPointer.SetActive(true);
                    standartLaser.laserDistance = 35f;
                    standartLaser.reticleDistance = 50f;

                    spmCapsul.Stop();
                    spmCapsul.pathContainer = null;

                    rigCapsul.isKinematic = true;
                    capsul.transform.localPosition = CTRLtriggersPoints.point[i].transform.localPosition;
                    capsul.transform.localRotation = CTRLtriggersPoints.point[i].transform.localRotation;


                    Debug.Log("хуяк point");
                }
            }            
        }
    }
}

///CTRLtriggersPoints.point[i] != null