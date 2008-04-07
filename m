From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 07 Apr 2008 09:05:59 +0000
Subject: Re: [DCCP]: Start implementation of queuing policies
Message-Id: <20080407090558.GH6146@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200804052115.33309.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804052115.33309.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| --- /dev/null
| +++ b/net/dccp/qpolicy.c

| +extern struct dccp_qpolicy_operations simple_policy_operations;
| +struct dccp_qpolicy_operations* qpolicy_operations[] 
When using something that returns a pointer, please tack the pointer to
the struct -- same with functions: "foo* bar" should be "foo *bar"

There are lots of these -- scripts/checkpatch.pl found 10 instances.
Can you please use the kernel CodingStyle.

| +
| +void qpolicy_push(struct sock *sk, struct sk_buff *skb, void* control, __kernel_size_t controllen)
Nit: This line has 102 characters, please use 80-character lines.
	
| --- /dev/null
| +++ b/net/dccp/qpolicy.h
| @@ -0,0 +1,36 @@
| +/*
| + *  net/dccp/qpolicy.h
| + *
| + *  An implementation of the DCCP protocol
| + *
| + *  Copyright (c) 2008 Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
| + *
| + *  This program is free software; you can redistribute it and/or
| + *  modify it under the terms of the GNU General Public License v2
| + *  as published by the Free Software Foundation.
| + */
| +
| +#ifndef _QPOLICY_H
| +#define _QPOLICY_H
| +
| +#include <linux/kernel.h>
| +#include <linux/socket.h>
| +#include "dccp.h"
| +
| +struct dccp_qpolicy_operations
| +{
Nit: struct declarations should use struct foo { ...   (bracket on same line, cf. CodingStyle).
	
| +	unsigned char policy_id;
| +
| +	/* Interface Routines */
| +	void (*push)(struct sock *sk, struct sk_buff *skb, void* control, __kernel_size_t controllen);
| +	int (*full)(struct sock *sk);
| +	struct sk_buff* (*top)(struct sock *sk);
| +	void (*pop)(struct sock *sk, struct sk_buff *skb);
| +};
| +
| +void qpolicy_push(struct sock *sk, struct sk_buff *skb, void* control, __kernel_size_t controllen);
| +int qpolicy_full(struct sock *sk);
| +struct sk_buff* qpolicy_top(struct sock *sk);
| +void qpolicy_pop(struct sock *sk, struct sk_buff *skb);
| +
The functions in qpolicy.c are all wrappers around the dccp_qpolicy_operations. The qpolicy.c file
declares these one-line functions. I think it would be better to declare the wrappers as "static inline"
in this header file, in the manner of ccid.h.


| --- /dev/null
| +++ b/net/dccp/qpolicy_simple.c
| @@ -0,0 +1,43 @@
| +/*
| + *  net/dccp/qpolicy_simple.c
| + *
| + *  An implementation of the DCCP protocol
| + *
| + *  Copyright (c) 2008 Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
| + *
| + *  This program is free software; you can redistribute it and/or
| + *  modify it under the terms of the GNU General Public License v2
| + *  as published by the Free Software Foundation.
| + */
| +
| +#include "qpolicy.h"
| +#define POLICY_ID 0
| +
| +void simple_push(struct sock *sk, struct sk_buff *skb, void* control, __kernel_size_t controllen)
Nit: length - please use 80 character lines.	All the functions can be
declared `static', since the are only linked within this file.
| +{
| +	skb_queue_tail(&sk->sk_write_queue, skb);
| +}
| +
| +int simple_full(struct sock *sk)
| +{
| +	return (sysctl_dccp_tx_qlen && (sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen));
| +}
| +
| +struct sk_buff* simple_top(struct sock *sk)
| +{
| +	return skb_peek(&sk->sk_write_queue);
| +}
| +
| +void simple_pop(struct sock *sk, struct sk_buff *skb)
| +{
| +	skb_unlink(skb, &sk->sk_write_queue);
| +}
| +
| +struct dccp_qpolicy_operations simple_policy_operations | +{
| +	.policy_id = POLICY_ID,
| +	.push = simple_push,
| +	.full = simple_full,
| +	.top = simple_top,
| +	.pop = simple_pop,
| +};


-- 


The University of Aberdeen is a charity registered in Scotland, No SC013683.

