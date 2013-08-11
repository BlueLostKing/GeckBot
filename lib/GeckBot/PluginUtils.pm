package GeckBot::PluginUtils;

use HTTP::Tiny;
use JSON::XS;
use IO::Socket::SSL;

=head3 load_tracking( $tracking_dir, $channel )

Load channel specific tracking data

input

=cut

sub load_tracking {
	my ( $tracking_dir, $channel ) = @_;

	$channel =~ s/\#//g;
	my $tracking_file = "${tracking_dir}/${channel}";
	my $tracking_data = { $channel => {} };

	if ( -e $tracking_file ) {
		open my $tracking_fh, '<', $tracking_file;
		my $tracking_string = <$tracking_fh>;
		eval { 
			$tracking_data = JSON::XS::decode_json($tracking_string);
		};
		if ( $@ ) {
			#todo: file-based logging
		}
		close $tracking_fh;
	}

	return $tracking_data;
}


=head3 shorten_url($url)

Shorten a URL using google's goo.gl service

input: $url - the URL you want to shorten

response - $short_url - the shortened version

=cut

sub shorten_url {
	my ( $url ) = @_;

	my $postdata = encode_json( { 'longUrl' => $url } );
	my $res = HTTP::Tiny->new->post( 'https://www.googleapis.com/urlshortener/v1/url', 
		{ 
			'content' => $postdata,
			'headers' => {
				'Content-Type' => 'application/json',
			},
		},
	);

	if ( $res->{'success'} ) {
		my $data = decode_json( $res->{'content'} );
		return $data->{'id'};
	}
	print STDERR "Could not retrieve short url for $url";
}
1;