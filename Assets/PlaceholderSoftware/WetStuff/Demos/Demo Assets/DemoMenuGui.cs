using UnityEngine;
using UnityEngine.SceneManagement;

namespace PlaceholderSoftware.WetStuff.Demos.Demo_Assets
{
    public class DemoMenuGui : MonoBehaviour
    {
        private void OnGUI()
        {
            using (new GUILayout.HorizontalScope())
            {
                GUILayout.Space(10);
                using (new GUILayout.VerticalScope())
                {
                    GUILayout.Space(10);

                    SceneButton("1. Puddle");
                    SceneButton("2. Timeline");
                    SceneButton("3. Rain");
                    SceneButton("4. Particles (Splat)");
                    SceneButton("5. Particles (Drip Drip Drip)");
                    SceneButton("6. Triplanar Mapping");
                    SceneButton("7. Dry Decals");
                }
            }
        }

        private static void SceneButton(string scene)
        {
            if (GUILayout.Button(scene))
                SceneManager.LoadScene(scene);
        }
    }
}
