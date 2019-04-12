using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class CTRL_FadeInfo : MonoBehaviour
{
    public static DOTweenAnimation fadeInfo;

    private void Awake()
    {
        fadeInfo = GetComponent<DOTweenAnimation>();
    }

    void Start()
    {
        
    }

    void Update()
    {
        
    }
}
