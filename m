From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 19 Oct 2009 05:23:13 +0000
Subject: Re: [PATCH 1/4] Adds random ect generation to tfrc-sp sender side
Message-Id: <20091019052313.GC3366@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <4AD4B790.9000701@embedded.ufcg.edu.br>
In-Reply-To: <4AD4B790.9000701@embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Adds random ect generation to tfrc-sp sender side.

I thought about this and found several reasons why it would be better to
defer ECN Nonce sums to a later implementation.

 1) At the moment the code always sets ECT(0). Even if it would
    alternate ECT(0) and ECT(1), this would later be overwritten by ECT(0)
    in dccp_msghdr_parse(). Ok, this could be fixed, but the real problem
    is that the underlying machinery does not support ECN nonces, since

    * ECN / DiffServ information is in two separate places of the
      inet_sock (u8 `tos' field and u8 `tclass' field of ipv6_pinfo);

    * the ECN driver sits in include/net/inet_ecn.h as
      #define INET_ECN_xmit(sk) do { inet_sk(sk)->tos |= INET_ECN_ECT_0; } while (0)

    * hence this would need to be revised and the best way to make an
      acceptable suggestion would be a coded proof of concept that 
      changing the underlying implementation does have benefits.

    On the receiver side the situation is the same. The function
    tfrc_sp_check_ecn_sum(), introduced in Patch 2/4 of the TFRC-SP sender
    implementation is only referenced in Patch 2/2 of the CCID-4 set, where
    it ends, without side effect in "TODO: consider ecn sum test fail".

    That is, at the moment both the sender and receiver side of the ECN Nonce
    sum verification are placeholders which currently have no effect.


 2) As far as I can see the ECN Nonce is an optimisation, an

      "optional addition to Explicit Congestion Notification [RFC3168]
       improving its robustness against malicious or accidental
       concealment of marked packets [...]" (from the abstract)

    Hence if at all, we would only have a benefit of adding the ECN Nonce
    verification on top of an already verified implementation.

 3) Starting an implementation throws up further questions that need to
    be addressed, both the basis and the extension need to be verified.

I would like to suggest to implement the basis, that is CCID-4 with ECN
(using plain ECT(0)), test with that until it works satisfactorily, and
then continue adding measures such as the ECN Nonce verification.

Nothing is lost, once we are at this stage we can return to this set of
initial patches and revise the situation based on the insights gained 
with ECT(0) experience.

In summary, I would like to suggest to remove the ECN verification for
the moment and focus on the "basic" issues first.

Would you be ok with that?



Appendix
--------
| +int tfrc_sp_get_random_ect(struct tfrc_tx_li_data *li_data, u64 seqn)
| +{
| +	int ect;
| +	struct tfrc_ecn_echo_sum_entry *sum;
| +
| +	/* TODO: implement random ect*/
| +	ect = INET_ECN_ECT_0;
| +
| +	sum = kmem_cache_alloc(tfrc_ecn_echo_sum_slab, GFP_ATOMIC);

For a later implementation, there should be protection against NULL, e.g.
        if (sum = NULL) {
	   DCCP_CRIT("Problem here ...");
	   return 0;
	}
| +
| +	sum->previous = li_data->ecn_sums_head;
| +	sum->ecn_echo_sum = (sum->previous->ecn_echo_sum) ? !ect : ect;

(Also for later) I wonder how to do the sums, with RFC 3168
ECT(0) = 0x2 => !0x2 = 0
ECT(1) = 0x1 => !0x1 = 0

From the addition table in RFC 3540, section 2,
ECT(0) + ECT(0) = 0
ECT(0) + ECT(1) = 1
ECT(1) + ECT(1) = 0

One way could be
        sum->ecn_echo_sum ^= (ect = INET_ECN_ECT_1);
