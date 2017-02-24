using UnityEngine;
using UnityEngine.Assertions;
using System.Collections;


/*
 * This is the MonoBehviour for controlling the special effects in the card shader.
 */
[RequireComponent(typeof(Animator))]
public class CardController : MonoBehaviour {

    private readonly string OnSelectTrigger = "OnSelect";
    private readonly string OnDeselectTrigger = "OnDeselect";

    private Animator cardAnimator;

    void Start()
    {
        cardAnimator = GetComponent<Animator>();
    }

    void Update () {
        // If the player presses space, we'll "select" the card.
	    if( Input.GetKeyDown(KeyCode.Space))
        {
            cardAnimator.SetTrigger(OnSelectTrigger);
        }
        else if (Input.anyKeyDown)
        {
            cardAnimator.SetTrigger(OnDeselectTrigger);
        }
    }
}
