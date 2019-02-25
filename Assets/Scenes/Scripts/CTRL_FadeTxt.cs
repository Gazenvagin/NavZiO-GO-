using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class CTRL_FadeTxt : MonoBehaviour
{
    public static DOTweenAnimation fadeText;

    private void Awake()
    {
        fadeText = GetComponent<DOTweenAnimation>();
    }

    void Start()
    {

    }

    void Update()
    {

    }
}