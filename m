From: Hangyu Hua <hbh25y@gmail.com>
Date: Wed, 22 Feb 2023 02:12:46 +0000
Subject: Re: [PATCH] net: dccp: delete redundant ackvec record in dccp_insert_options()
Message-Id: <a953cdd9-1cf6-f976-fb6f-4ce0c5d9f3b7@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230221092206.39741-1-hbh25y@gmail.com>
In-Reply-To: <20230221092206.39741-1-hbh25y@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 21/2/2023 20:46, Eric Dumazet wrote:
> On Tue, Feb 21, 2023 at 10:22 AM Hangyu Hua <hbh25y@gmail.com> wrote:
>>
>> A useless record can be insert into av_records when dccp_insert_options()
>> fails after dccp_insert_option_ackvec(). Repeated triggering may cause
>> av_records to have a lot of useless record with the same avr_ack_seqno.
>>
>> Fixes: 8b7b6c75c638 ("dccp: Integrate feature-negotiation insertion code")
>> Signed-off-by: Hangyu Hua <hbh25y@gmail.com>
>> ---
>>   net/dccp/options.c | 12 ++++++++++--
>>   1 file changed, 10 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/dccp/options.c b/net/dccp/options.c
>> index d24cad05001e..8aa4abeb15ea 100644
>> --- a/net/dccp/options.c
>> +++ b/net/dccp/options.c
>> @@ -549,6 +549,8 @@ static void dccp_insert_option_padding(struct sk_buff *skb)
>>   int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
>>   {
>>          struct dccp_sock *dp = dccp_sk(sk);
>> +       struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
>> +       struct dccp_ackvec_record *avr;
>>
>>          DCCP_SKB_CB(skb)->dccpd_opt_len = 0;
>>
>> @@ -577,16 +579,22 @@ int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
>>
>>          if (dp->dccps_hc_rx_insert_options) {
>>                  if (ccid_hc_rx_insert_options(dp->dccps_hc_rx_ccid, sk, skb))
>> -                       return -1;
>> +                       goto delete_ackvec;
>>                  dp->dccps_hc_rx_insert_options = 0;
>>          }
>>
>>          if (dp->dccps_timestamp_echo != 0 &&
>>              dccp_insert_option_timestamp_echo(dp, NULL, skb))
>> -               return -1;
>> +               goto delete_ackvec;
>>
>>          dccp_insert_option_padding(skb);
>>          return 0;
>> +
>> +delete_ackvec:
>> +       avr = dccp_ackvec_lookup(&av->av_records, DCCP_SKB_CB(skb)->dccpd_seq);
> 
> Why avr would be not NULL ?
> 
>> +       list_del(&avr->avr_node);
>> +       kmem_cache_free(dccp_ackvec_record_slab, avr);
>> +       return -1;
>>   }
> 
> Are you really using DCCP and/or how have you tested this patch ?
> 
> net/dccp/ackvec.c:15:static struct kmem_cache *dccp_ackvec_record_slab;
> 
> I doubt this patch has been compiled.
> 
> I would rather mark DCCP deprecated and stop trying to fix it.

My bad. I will fix these problems.

Thanks,
Hangyu
