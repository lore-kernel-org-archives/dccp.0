From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 08 Feb 2010 06:20:28 +0000
Subject: [PATCH 1/1] dccp: allow probing of CCID-array length
Message-Id: <20100208062028.GA5478@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes a problem in the DCCP getsockopt() API: currently there is no way
for a user to a priori know the number of built-in CCIDs, other than trying
DCCP_SOCKOPT_AVAILABLE_CCIDS in a loop, incrementing the option length until
EINVAL is no longer returned.

This patch truncates the array to the user-provided length. No copy is made
when the length is <= 0.

Due to the length restriction in do_dccp_getsockopt() to sizeof(int), the
minimum array length remains 4, which is a reasonable default (only 3
CCIDs, CCID-2..4, are currently defined).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/dccp.txt |    6 ++++--
 net/dccp/ccid.c                   |    9 ++++-----
 2 files changed, 8 insertions(+), 7 deletions(-)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -58,8 +58,10 @@ DCCP_SOCKOPT_GET_CUR_MPS is read-only and retrieves the current maximum packet
 size (application payload size) in bytes, see RFC 4340, section 14.
 
 DCCP_SOCKOPT_AVAILABLE_CCIDS is also read-only and returns the list of CCIDs
-supported by the endpoint (see include/linux/dccp.h for symbolic constants).
-The caller needs to provide a sufficiently large (> 2) array of type uint8_t.
+supported by the endpoint. The option value is an array of type uint8_t whose
+size is passed as option length. The minimum array size is 4 elements, the
+value returned in the optlen argument always reflects the true number of
+built-in CCIDs.
 
 DCCP_SOCKOPT_CCID is write-only and sets both the TX and RX CCIDs at the same
 time, combining the operation of the next two socket options. This option is
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -63,14 +63,13 @@ int ccid_getsockopt_builtin_ccids(struct sock *sk, int len,
 	u8 *ccid_array, array_len;
 	int err = 0;
 
-	if (len < ARRAY_SIZE(ccids))
-		return -EINVAL;
-
 	if (ccid_get_builtin_ccids(&ccid_array, &array_len))
 		return -ENOBUFS;
 
-	if (put_user(array_len, optlen) ||
-	    copy_to_user(optval, ccid_array, array_len))
+	if (put_user(array_len, optlen))
+		err = -EFAULT;
+	else if (len > 0 && copy_to_user(optval, ccid_array,
+					 len > array_len ? array_len : len))
 		err = -EFAULT;
 
 	kfree(ccid_array);

