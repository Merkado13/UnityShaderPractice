using System.Collections;
using System.Collections.Generic;
using System.Transactions;
using UnityEngine;

public class Child : Parent
{
    // Start is called before the first frame update
    void Start()
    {
        Debug.Log(integer);
    }

    // Update is called once per frame
    void Update()
    {
        //integer = 2;
    }

    public override void TestOverride()
    {
        Debug.Log("Sobrescribiendo");
    }

    protected override void Test()
    {
        base.Test(); 
    }
}
