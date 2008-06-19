From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 19 Jun 2008 08:21:43 +0000
Subject: Re: QUESTION : Feature length about the non-negotiable feature
Message-Id: <20080619082143.GA8680@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <48579530.4010807@cn.fujitsu.com>
In-Reply-To: <48579530.4010807@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>> This has been tested, I will post the changelog for the test tree
>> shortly and upload the amended tree. I would be grateful if you could
>> give this a spin with your test cases.
>>
>>   
>
> With the patch, it is OK for send non-negotiable features. But not valid  
> for check invalid value when recv.
>
>
Thank you for testing. I don't understand your second sentence: all NN
options are value-checked, i.e. if you try a Sequence Window of less
than 32 or greater than 2^46-1, the connection should be reset.
Likewise, Ack Ratio is checked to be in the range 0..0xFFFF.

I guess you are meaning `length' rather than `value'.

It is certainly possible to implement that. 

But it will kill any connection which has NN options with a valid value but
unorthodox length. If that is what people want, then the following happens:

 * NN Change L arrives with valid value, but results in an empty
   Confirm R since the length is unorthodox with regard to RFC 4340;
 * receiving empty Confirm R resets the connection;
 * with mandatory options the Reset will happen even earlier;
 * a NN Confirm R with valid value (i.e. corresponding to the original
   value of the Change L) resets the connection as per RFC 4340, 6.6.8.
