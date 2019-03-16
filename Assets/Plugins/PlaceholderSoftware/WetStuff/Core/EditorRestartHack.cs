using System;
using System.Collections;
using UnityEditor;
using UnityEngine;

namespace PlaceholderSoftware.WetStuff
{
    /// <summary>
    ///     In edit mode the wet decal effect sometimes does not render even when the command buffers are all attached to the
    ///     camera. This appears to be a Unity issue caused by the effect
    ///     applying the command buffers very early (some kind of initialisation order problem) - disabling and enabling the
    ///     component always fixes the issue. This component automatically
    ///     disables and immediately re-enables the decal renderer to work around this.
    /// </summary>
    internal class EditorRestartHack
        : MonoBehaviour
    {
        private IEnumerator _enumerator;
        private WetStuff _renderer;

        public void Awake()
        {
            hideFlags = HideFlags.HideAndDontSave;
        }

        public void Apply(WetStuff decalRenderer)
        {
#if UNITY_EDITOR
            _renderer = decalRenderer;
            _enumerator = RestartCoroutine();
            EditorApplication.update += OnEditorUpdate;
#else
            DestroyImmediate(this);
#endif
        }

#if UNITY_EDITOR
        private IEnumerator RestartCoroutine()
        {
            if (_renderer == null)
                yield break;

            _renderer.enabled = false;

            //Wait for 3 frames and 0.1 seconds to pass
            var startTime = DateTime.UtcNow;
            for (var j = 0; j < 3 && DateTime.UtcNow - startTime < TimeSpan.FromSeconds(0.1); j++)
                yield return true;

            _renderer.enabled = true;
        }

        private void OnEditorUpdate()
        {
            // Real coroutines don't work in editor, so we're going to fake it
            if (!_enumerator.MoveNext())
            {
                // ReSharper disable once DelegateSubtraction
                EditorApplication.update -= OnEditorUpdate;

                DestroyImmediate(this);
            }
        }
#endif
    }
}