From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 03 Dec 2006 15:26:20 +0000
Subject: Re: [PATCH 5/8]: Add protection against invalid parameters
Message-Id: <200612031526.20401@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612011827.01580@strip-the-willow>
In-Reply-To: <200612011827.01580@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  The
|  reason I say this is good as in the back of my mind I am thinking of
|  people looking for DoS vulnerabilities...
|  
|  However BUG_ON does work and forces the code to get tidied so the
|  condition doesn't occur again. So whichever way I'm happy to go ahead
|  with it.
What you are saying is very important and I suggest auditing the code against
calling this function with invalid parameters as next to-do.

I would further like to inform you and Arnaldo that I have ironed out an error
of mine in this patch (uploaded), namely the following

--- a/net/dccp/ccids/lib/tfrc_equation.c
+++ b/net/dccp/ccids/lib/tfrc_equation.c
@@ -19,7 +19,7 @@ #include "tfrc.h"
 
 #define TFRC_CALC_X_ARRSIZE 500
 #define TFRC_CALC_X_SPLIT   50000	/* 0.05 * 1000000, details below */
-#define TFRC_SMALLEST_P	    TFRC_CALC_X_SPLIT/TFRC_CALC_X_ARRSIZE
+#define TFRC_SMALLEST_P	    (TFRC_CALC_X_SPLIT/TFRC_CALC_X_ARRSIZE)
 

This is required since later on the code calls
  index = p/TFRC_SMALLEST_P -1;
which cpp expands as
 index = p/TFRC_CALC_X_SPLIT/TFRC_CALC_X_ARRSIZE -1;
       = (p/TFRC_CALC_X_SPLIT)/TFRC_CALC_X_ARRSIZE -1;
since `/' associates to the left. This can lead to an index of -1 (boom!).

This is fixed in the uploaded version.
