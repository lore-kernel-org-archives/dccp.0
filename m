From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 08 Jul 2008 09:26:33 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
Message-Id: <20080708092633.GB5668@gerrit.erg.abdn.ac.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="IJpNTDwzlM2Ie8A6"
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
To: dccp@vger.kernel.org


--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Thank you for those scenarios -- the problem is now better to understand.

| I would like to know how applications are supposed to use DCCP in 4 scenarios:
(1) ... (3) can be handled without too many ambiguities; (4) seems to be the 
key point.

| 1. The application wants to use the old behaviour (that is simple policy with 
|    no parameters).
By setting the ID for the `simple' policy (which does not use parameters) to 0.

| 2. The application wants to use prio policy but needs no parameters.
That should not be a problem if we only check the supplied parameters.

The prio policy (any policy for that matter) needs a way of interpreting
the absence of parameters meaningfully.

| 3. The application wants to attach priority information to each packet.
This would be the default/expected case.


| 4. The application wants to attach priority and timeout information to each 
|    packet. If kernel cannot process timeout then fall back to priority 
|    information only.
I can think of at least two ways of tackling this -- maybe there are more:

  (a) Separate policies for "prio" and "prio with timeout"
      ---------------------------------------------------
      Would be resolved when trying to set "prio with timeout" policy - the
      kernel would either accept (and understand) it or return an error.

  (b) Use of optional parameters
      --------------------------
      If I understand you correctly, this is actually the way you would
      design the use of parameters, and my understanding of it is to
      that there are a few basic (well-defined) policies which could be
      combined with a number of optional additional parameters -- is that
      your idea? If this is the case then we need to step back and sort 
      out the base policies plus set of optional parameters, and find a
      way of dealing with each combination. At first sight, this seems
      more difficult and complicated than (a).

Not directly related to above questions, but rather as inspiration I
attach the sketch which I did for the definition of qpolicies. The idea
is to use a separate enum for each combination of parameters. The first
entry is initialised using the parameter bitmask, subsequent entries
have subsequent numbers.

--IJpNTDwzlM2Ie8A6
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="main.c"

#include <stdio.h>

enum qpolicy_params {
	QP_PARAM_PRIO  = 0x1,
	QP_PARAM_TIMEO = 0x2,
	/* ... */
};

/* 4 bits = up to 16 policies sharing the same set of parameters */
#define QPOLICY_PARAM_SHIFT		4
#define QPOLICY_INITIALISER(params)	((params) << QPOLICY_PARAM_SHIFT)

enum qpolicies_that_are_without_parameters {
	DCCPQ_POLICY_SIMPLE		= 0,
	DCCPQ_POLICY_SIMPLE_DROP_ON_FULL,
};

enum qpolicies_using_only_the_prio_parameter {
	DCCPQ_POLICY_PRIO		= QPOLICY_INITIALISER(QP_PARAM_PRIO),
	DCCPQ_POLICY_REVERSE_PRIO,
	DCCPQ_POLICY_HEAP
};

enum qpolicies_using_only_the_timeo_parameter {
	DCCPQ_POLICY_TIMEO		= QPOLICY_INITIALISER(QP_PARAM_TIMEO),
};

enum qpolicies_using_both_prio_and_timeo_parameters {
	DCCPQ_POLICY_TIMED_PRIO		= QPOLICY_INITIALISER(QP_PARAM_PRIO|QP_PARAM_TIMEO),
	DCCPQ_POLICY_TIMED_REVERSE_PRIO,
	DCCPQ_POLICY_SEND_BEST_PACKET_NEXT
};

int main(void)
{
	printf("simple:                     %08x\n",   DCCPQ_POLICY_SIMPLE);
	printf("simple, dropping when full: %08x\n\n", DCCPQ_POLICY_SIMPLE_DROP_ON_FULL);

	printf("priority:                   %08x\n",   DCCPQ_POLICY_PRIO);
	printf("reverse priority:           %08x\n",   DCCPQ_POLICY_REVERSE_PRIO);
	printf("heap-based priority:        %08x\n\n", DCCPQ_POLICY_HEAP);

	printf("plain timeout:              %08x\n\n", DCCPQ_POLICY_TIMEO);

	printf("priority with timeout:      %08x\n",   DCCPQ_POLICY_TIMED_PRIO);
	printf("rev. prio. with timeout:    %08x\n",   DCCPQ_POLICY_TIMED_REVERSE_PRIO);
	printf("send-best-packet-next:      %08x\n",   DCCPQ_POLICY_SEND_BEST_PACKET_NEXT);

	return 0;
}

--IJpNTDwzlM2Ie8A6--
