From: Patrick McHardy <kaber@trash.net>
Date: Fri, 11 Apr 2008 13:41:33 +0000
Subject: Re: [DCCP]: Fix skb->cb conflicts with IP
Message-Id: <47FF6A8D.30705@trash.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------020302070507040701080709"
List-Id: <dccp.vger.kernel.org>
References: <47F61B5C.8090105@trash.net>
In-Reply-To: <47F61B5C.8090105@trash.net>
To: dccp@vger.kernel.org

This is a multi-part message in MIME format.
--------------020302070507040701080709
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Arnaldo Carvalho de Melo wrote:
> Em Fri, Apr 04, 2008 at 02:13:16PM +0200, Patrick McHardy escreveu:
> 
>> commit eced67957ee99f7b5fafdc73a58bcd037a1789b2
>> Author: Patrick McHardy <kaber@trash.net>
>> Date:   Fri Apr 4 14:10:23 2008 +0200
>>
>>     [DCCP]: Fix skb->cb conflicts with IP
>>     
>>     dev_queue_xmit() and the other IP output functions expect to get a skb
>>     with clear or properly initialized skb->cb. Unlike TCP and UDP, the
>>     dccp_skb_cb doesn't contain a struct inet_skb_parm at the beginning,
>>     so the DCCP-specific data is interpreted by the IP output functions.
>>     This can cause false negatives for the conditional POST_ROUTING hook
>>     invocation, making the packet bypass the hook.
>>     
>>     Add a inet_skb_parm/inet6_skb_parm union to the beginning of
>>     dccp_skb_cb to avoid clashes. Also add a BUILD_BUG_ON to make
>>     sure it fits in the cb.
>>     
>>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> Thanks Patrick,
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>


Dave, I'm not sure whether you've missed this or expect it
to go through Arnaldo, just want to make sure it doesn't
get missed because of a misunderstanding :)



--------------020302070507040701080709
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit eced67957ee99f7b5fafdc73a58bcd037a1789b2
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Apr 4 14:10:23 2008 +0200

    [DCCP]: Fix skb->cb conflicts with IP
    
    dev_queue_xmit() and the other IP output functions expect to get a skb
    with clear or properly initialized skb->cb. Unlike TCP and UDP, the
    dccp_skb_cb doesn't contain a struct inet_skb_parm at the beginning,
    so the DCCP-specific data is interpreted by the IP output functions.
    This can cause false negatives for the conditional POST_ROUTING hook
    invocation, making the packet bypass the hook.
    
    Add a inet_skb_parm/inet6_skb_parm union to the beginning of
    dccp_skb_cb to avoid clashes. Also add a BUILD_BUG_ON to make
    sure it fits in the cb.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index fe7726b..f44d492 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -325,6 +325,12 @@ static inline int dccp_bad_service_code(const struct sock *sk,
  * This is used for transmission as well as for reception.
  */
 struct dccp_skb_cb {
+	union {
+		struct inet_skb_parm	h4;
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+		struct inet6_skb_parm	h6;
+#endif
+	} header;
 	__u8  dccpd_type:4;
 	__u8  dccpd_ccval:4;
 	__u8  dccpd_reset_code,
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index e3f5d37..c91d3c1 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1057,6 +1057,9 @@ static int __init dccp_init(void)
 	int ehash_order, bhash_order, i;
 	int rc = -ENOBUFS;
 
+	BUILD_BUG_ON(sizeof(struct dccp_skb_cb) >
+		     FIELD_SIZEOF(struct sk_buff, cb));
+
 	dccp_hashinfo.bind_bucket_cachep =
 		kmem_cache_create("dccp_bind_bucket",
 				  sizeof(struct inet_bind_bucket), 0,

--------------020302070507040701080709--
