From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 13 Sep 2009 18:50:50 +0000
Subject: Re: [PATCH 5/5] Updating documentation accordingly
Message-Id: <20090913185050.GA7475@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011946g744a4f5cvbe6a2e7642eaa8ff@mail.gmail.com>
In-Reply-To: <cb00fa210909011946g744a4f5cvbe6a2e7642eaa8ff@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Updating documentation accordingly

+/* As defined at section 8.6.1. of RFC 4342 */
 #define TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH	28
+/* Specified on section 8.7. of CCID4 draft */
 #define TFRC_DROP_OPT_MAX_LENGTH		84
Need to update the references to CCID4 draft with RFC 5622. See also 4/5.

It would be more helpful to include the documentation for structs with
the patches that use these structs.
