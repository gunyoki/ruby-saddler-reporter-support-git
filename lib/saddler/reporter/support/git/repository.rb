module Saddler
  module Reporter
    module Support
      module Git
        class Repository
          def initialize(path)
            @git = ::Git.open(path)
          end

          def slug
            name = /[[:alnum:]_\-\.]*/
            repo = /[[:alnum:]_\-\.]*/
            regex_slug = %r{#{name}/#{repo}}
            regex = /.*?#{Regexp.quote(github_domain)}.*?(?<slug>#{regex_slug})/
            target = remote_urls.map do |url|
              match = regex.match(strip_git_extension(url))
              match[:slug] if match
            end.compact.first
          end

          def remote_urls
            @git
              .branches
              .remote
              .map { |branch| branch.remote.url }
          end

          def current_branch
            @git.current_branch
          end

          def head
            @git.object('HEAD')
          end

          def strip_git_extension(name)
            match = /\A(?<identity>.*?)(?:\.git)?\z/.match(name)
            match[:identity] if match
          end

          # FIXME: if endpoint set, this return wrong result
          def github_domain
            github_api_endpoint
              .split('.')
              .slice(-2, 2)
              .join('.')
          end

          def github_api_endpoint
            ENV['GITHUB_API_ENDPOINT'] || 'api.github.com'
          end
        end
      end
    end
  end
end
