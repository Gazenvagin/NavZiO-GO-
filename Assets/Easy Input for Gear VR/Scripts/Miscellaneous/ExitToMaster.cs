using UnityEngine;
using System;
using System.Collections;
using EasyInputVR.Core;
using UnityEngine.SceneManagement;
using EasyInputVR.Misc;
using EasyInputVR.StandardControllers;

namespace EasyInputVR.Misc
{

    [AddComponentMenu("EasyInputGearVR/Miscellaneous/ExitToMaster")]
    public class ExitToMaster : MonoBehaviour
    {
        GameObject capsul;
        public Transform respawnSky;

        private pointerSwitch laserCapsul;
        private StandardLaserPointer standartLaser;

        void OnEnable()
        {
            EasyInputHelper.On_ClickStart += localClickStart;
        }

        void OnDestroy()
        {
            EasyInputHelper.On_Click -= localClickStart;
        }

        private void Start()
        {
            capsul = GetComponent<CTRL>().capsul;
            laserCapsul = capsul.GetComponent<pointerSwitch>();
            standartLaser = laserCapsul.laserPointer.GetComponent<StandardLaserPointer>();
        }

        void localClickStart(ButtonClick button)
        {
            if (EasyInputHelper.isGearVR || Application.isEditor)
            {
                if (button.button == EasyInputConstants.CONTROLLER_BUTTON.Back)
                {
                    RenderSettings.skybox = CTRL_SkyMat.mSkyFly;

                    //CTRL_TeleportOnOf.teleportOnOf.enabled = false;
                    CTRL_TeleportOnOf.groundTriggerPlant.enabled = false;

                    CTRL_FadeCam.fadeCam.delay = 0.15f;
                    CTRL_FadeCam.fadeCam.duration = 2.1f;
                    CTRL_FadeCam.fadeCam.DORestartById("fadeCam");
                    CTRL_FadeCam.fadeCam.DOPlayById("fadeCam");
                    CTRL.mainMenu.SetActive(true);
                    CTRL.logos.SetActive(true);

                    standartLaser.laserDistance = 2501f;
                    standartLaser.reticleDistance = 3001f;

                    capsul.transform.position = respawnSky.position;
                    capsul.transform.rotation = respawnSky.rotation;
                }
            }
        }

    }
}