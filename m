From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 18 Jun 2007 02:06:17 +0000
Subject: [PATCH 1/4] [KTIME]: Introduce ktime_us_delta
Message-Id: <20070618020617.GB4226@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This provides a reusable time difference function which returns the difference in
microseconds, as often used in the DCCP code.

Commiter note: renamed ktime_delta to ktime_us_delta and put it in ktime.h.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 include/linux/ktime.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/ktime.h b/include/linux/ktime.h
index c762954..a208f9f 100644
--- a/include/linux/ktime.h
+++ b/include/linux/ktime.h
@@ -267,6 +267,11 @@ static inline s64 ktime_to_us(const ktime_t kt)
 	return (s64) tv.tv_sec * USEC_PER_SEC + tv.tv_usec;
 }
 
+static inline s64 ktime_us_delta(const ktime_t later, const ktime_t earlier)
+{
+       return ktime_to_us(ktime_sub(later, earlier));
+}
+
 /*
  * The resolution of the clocks. The resolution value is returned in
  * the clock_getres() system call to give application programmers an
-- 
1.5.0.6

