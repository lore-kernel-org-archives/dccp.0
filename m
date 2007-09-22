From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 22 Sep 2007 19:31:49 +0000
Subject: Re: [PATCH 1/5]: Shorten variable names in dccp_check_seqno
Message-Id: <20070922193149.GB4887@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Sun, Jul 01, 2007 at 03:54:12PM +1200, Ian McDonald escreveu:
> On 6/20/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>> [DCCP]: Shorten variable names in dccp_check_seqno
>>
>> This patch is in part required by the next patch; it
>>
>>  * replaces 6 instances of `DCCP_SKB_CB(skb)->dccpd_seq' with `seqno';
>>  * replaces 7 instances of `DCCP_SKB_CB(skb)->dccpd_ack_seq' with `ackno';
>>  * replaces 1 use of dccp_inc_seqno() by unfolding `ADD48' macro in place.
>>
>> No changes in algorithm, all changes are text replacement/substitution.
>>
>> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
>> ---
>>  net/dccp/input.c |   40 +++++++++++++++++-----------------------
>>  1 file changed, 17 insertions(+), 23 deletions(-)
>>
>> --- a/net/dccp/input.c
>> +++ b/net/dccp/input.c
>> @@ -68,7 +68,8 @@ static int dccp_check_seqno(struct sock
>>  {
>>         const struct dccp_hdr *dh = dccp_hdr(skb);
>>         struct dccp_sock *dp = dccp_sk(sk);
>> -       u64 lswl, lawl;
>> +       u64 lswl, lawl, seqno = DCCP_SKB_CB(skb)->dccpd_seq,
>> +                       ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
>>
> I think this would be better served by a macro e.g.
> #define SEQNO DCCP_SKB_CB(skb)->dccpd_seq
>
> With the change you're making here you're increasing stack usage by 16 
> bytes.

But at least in another metric we gain back some bytes, the number of
inline expansions is reduced and with that the binary size is shrunk by
65 bytes on 32 bit arches:

[acme@filo net-2.6.24]$ codiff -V /tmp/input.o.before ../build/net-2.6.24/t/net/dccp/input.o
/home/acme/git/net-2.6.24/net/dccp/input.c:
  dccp_check_seqno |  -65 # 1132 -> 1067, # inlines: 7 -> 6, size inlines: 396 -> 360
   1 function changed, 65 bytes removed

Humm, codiff should show changes on variables... /me adds it to the TODO
list :-)

- Arnaldo
