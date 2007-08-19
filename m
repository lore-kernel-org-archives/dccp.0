From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 23:50:22 +0000
Subject: [PATCH 06/15] Introduce ktime_sub_ns and ktime_sub_us
Message-Id: <20070819235022.GJ24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

First user will be the DCCP transport networking protocol.

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 include/linux/ktime.h |   21 +++++++++++++++++++++
 kernel/hrtimer.c      |   24 ++++++++++++++++++++++++
 2 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/include/linux/ktime.h b/include/linux/ktime.h
index dae7143..a6ddec1 100644
--- a/include/linux/ktime.h
+++ b/include/linux/ktime.h
@@ -102,6 +102,13 @@ static inline ktime_t ktime_set(const long secs, const unsigned long nsecs)
 #define ktime_add_ns(kt, nsval) \
 		({ (ktime_t){ .tv64 = (kt).tv64 + (nsval) }; })
 
+/*
+ * Subtract a scalar nanosecod from a ktime_t variable
+ * res = kt - nsval:
+ */
+#define ktime_sub_ns(kt, nsval) \
+		({ (ktime_t){ .tv64 = (kt).tv64 - (nsval) }; })
+
 /* convert a timespec to ktime_t format: */
 static inline ktime_t timespec_to_ktime(struct timespec ts)
 {
@@ -200,6 +207,15 @@ static inline ktime_t ktime_add(const ktime_t add1, const ktime_t add2)
 extern ktime_t ktime_add_ns(const ktime_t kt, u64 nsec);
 
 /**
+ * ktime_sub_ns - Subtract a scalar nanoseconds value from a ktime_t variable
+ * @kt:		minuend
+ * @nsec:	the scalar nsec value to subtract
+ *
+ * Returns the subtraction of @nsec from @kt in ktime_t format
+ */
+extern ktime_t ktime_sub_ns(const ktime_t kt, u64 nsec);
+
+/**
  * timespec_to_ktime - convert a timespec to ktime_t format
  * @ts:		the timespec variable to convert
  *
@@ -289,6 +305,11 @@ static inline ktime_t ktime_add_us(const ktime_t kt, const u64 usec)
 	return ktime_add_ns(kt, usec * 1000);
 }
 
+static inline ktime_t ktime_sub_us(const ktime_t kt, const u64 usec)
+{
+	return ktime_sub_ns(kt, usec * 1000);
+}
+
 /*
  * The resolution of the clocks. The resolution value is returned in
  * the clock_getres() system call to give application programmers an
diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
index c21ca6b..5d885fc 100644
--- a/kernel/hrtimer.c
+++ b/kernel/hrtimer.c
@@ -277,6 +277,30 @@ ktime_t ktime_add_ns(const ktime_t kt, u64 nsec)
 }
 
 EXPORT_SYMBOL_GPL(ktime_add_ns);
+
+/**
+ * ktime_sub_ns - Subtract a scalar nanoseconds value from a ktime_t variable
+ * @kt:		minuend
+ * @nsec:	the scalar nsec value to subtract
+ *
+ * Returns the subtraction of @nsec from @kt in ktime_t format
+ */
+ktime_t ktime_sub_ns(const ktime_t kt, u64 nsec)
+{
+	ktime_t tmp;
+
+	if (likely(nsec < NSEC_PER_SEC)) {
+		tmp.tv64 = nsec;
+	} else {
+		unsigned long rem = do_div(nsec, NSEC_PER_SEC);
+
+		tmp = ktime_set((long)nsec, rem);
+	}
+
+	return ktime_sub(kt, tmp);
+}
+
+EXPORT_SYMBOL_GPL(ktime_add_ns);
 # endif /* !CONFIG_KTIME_SCALAR */
 
 /*
-- 
1.5.2.2

