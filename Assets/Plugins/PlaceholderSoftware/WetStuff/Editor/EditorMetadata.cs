using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using UnityEngine;

namespace PlaceholderSoftware.WetStuff
{
    /// <summary>
    ///     Get some anonymised metadata about the current editor
    /// </summary>
    internal class EditorMetadata
    {
        /// <summary>
        ///     Get an anonymous unique ID for this user
        /// </summary>
        /// <returns></returns>
        [NotNull]
        private static string UserId()
        {
            // These are the parts which go into making the unique ID
            // These do NOT get sent anywhere!
            var parts = string.Join("-", new[] {
                Environment.MachineName,
                Environment.UserName
            });

            // Generate the SHA hash of the above string. This is cryptographically irreversible so it's unique per user but the above data can't possibly be recovered.
            using (var sha512 = SHA1.Create())
                return WWW.EscapeURL(Convert.ToBase64String(sha512.ComputeHash(Encoding.UTF8.GetBytes(parts))).Replace("+", "").Replace("/", ""));
        }

        /// <summary>
        ///     Get the version of the editor
        /// </summary>
        /// <returns></returns>
        [NotNull]
        private static string UnityVersion()
        {
            return WWW.EscapeURL(Application.unityVersion);
        }

        /// <summary>
        ///     Get a query string containing editor metadata
        /// </summary>
        /// <param name="utmMedium">Where you're going to be using this string from</param>
        /// <param name="parts">Additional bits to add into the query string</param>
        /// <returns></returns>
        [NotNull]
        internal static string GetQueryString([NotNull] string utmMedium, [CanBeNull] IEnumerable<KeyValuePair<string, string>> parts = null)
        {
            var qStringParts = new[] {
                new { k = "uid", v = UserId() },
                new { k = "uve", v = UnityVersion() },
                new { k = "wve", v = WWW.EscapeURL(WetStuff.Version.ToString()) },
                new { k = "utm_source", v = "unity_editor" },
                new { k = "utm_medium", v = WWW.EscapeURL(utmMedium) },
                new { k = "utm_campaign", v = "unity_editor_wetsurfacedecals" }
            };

            var extensions = (parts ?? new KeyValuePair<string, string>[0])
               .Select(a => new {
                    k = a.Key,
                    v = a.Value
                })
               .Concat(qStringParts)
               .Select(a => string.Format("{0}={1}", a.k, a.v))
               .ToArray();

            return "?" + string.Join("&", extensions.ToArray());
        }
    }
}