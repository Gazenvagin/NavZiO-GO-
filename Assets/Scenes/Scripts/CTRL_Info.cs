using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using DG.Tweening.Core;

public class CTRL_Info : MonoBehaviour
{
    public GameObject[] infoShelf;

    void Start()
    {
        for (int i = 0; i < infoShelf.Length; i++)
        {
            infoShelf[i].SetActive(false);
        }
    }

    void Update()
    {
        
    }

    public void CloseInfoShelf()
    {
        for (int i = 0; i < infoShelf.Length; i++)
        {
            infoShelf[i].SetActive(false);
            StopCoroutine(CloseInfo());
        }
    }

    IEnumerator CloseInfo()
    {
        yield return new WaitForSeconds(15f);

        for (int i = 0; i < infoShelf.Length; i++)
        {
            infoShelf[i].SetActive(false);
        }
        StopCoroutine(CloseInfo());
    }

    public void Show_Hide_Info_Proh()
    {
        for (int i = 0; i < infoShelf.Length; i++)
        {
            if (!infoShelf[0].activeSelf)
            {
                infoShelf[0].SetActive(true);

                StartCoroutine( CloseInfo() );

                CTRL_FadeInfo.fadeInfo.targetGO = infoShelf[0];                
                CTRL_FadeInfo.fadeInfo.animationType = DOTweenAnimation.AnimationType.Fade;
                CTRL_FadeInfo.fadeInfo.delay = 0f;
                CTRL_FadeInfo.fadeInfo.duration = 1f;
                CTRL_FadeInfo.fadeInfo.isFrom = true;
                CTRL_FadeInfo.fadeInfo.DOPlayById("fadeInfo");

                CTRL_FadeTxt.fadeText.delay = 0f;
                CTRL_FadeTxt.fadeText.duration = 3f;
                CTRL_FadeTxt.fadeText.DOPlay();

            }
            else
            {
                infoShelf[i].SetActive(false);
                StopCoroutine(CloseInfo());
            }
        }        
    }
}
