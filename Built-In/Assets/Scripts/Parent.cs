using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Parent : MonoBehaviour
{

    [SerializeField]
    protected int integer;

    
    
    private void Awake()
    {
        integer = 24;
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    protected virtual void Test() 
    {
        TestOverride();
    }

    public abstract void TestOverride();
}
