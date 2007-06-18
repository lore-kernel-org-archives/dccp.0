From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 18 Jun 2007 02:06:38 +0000
Subject: [PATCH 2/4] [KTIME]: Introduce ktime_add_us
Message-Id: <20070618020638.GC4226@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 include/linux/ktime.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/ktime.h b/include/linux/ktime.h
index a208f9f..9800bae 100644
--- a/include/linux/ktime.h
+++ b/include/linux/ktime.h
@@ -272,6 +272,11 @@ static inline s64 ktime_us_delta(const ktime_t later, const ktime_t earlier)
        return ktime_to_us(ktime_sub(later, earlier));
 }
 
+static inline ktime_t ktime_add_us(const ktime_t kt, const u64 usec)
+{
+	return ktime_add_ns(kt, usec * 1000);
+}
+
 /*
  * The resolution of the clocks. The resolution value is returned in
  * the clock_getres() system call to give application programmers an
-- 
1.5.0.6

