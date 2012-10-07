module Spree
  module Admin
    class ImageSettingsController < Spree::Admin::BaseController
      def show
        styles = ActiveSupport::JSON.decode(Spree::Config[:attachment_styles])
        @styles_list = styles.collect { |k, v| k }.join(", ")
      end

      def edit
        @styles = ActiveSupport::JSON.decode(Spree::Config[:attachment_styles])
        @headers = ActiveSupport::JSON.decode(Spree::Config[:s3_headers])
      end

      def update
        update_styles(params)
        update_headers(params) if Spree::Config[:use_s3]

        Spree::Config.set(params[:preferences])
        update_paperclip_settings

        respond_to do |format|
          format.html {
            flash[:notice] = t(:image_settings_updated)
            redirect_to admin_image_settings_path
          }
        end
      end


      private

      def update_styles(params)
        params[:new_attachment_styles].each do |index, style|
          params[:attachment_styles][style[:name]] = style[:value] unless style[:value].empty?
        end if params[:new_attachment_styles].present?

        styles = params[:attachment_styles]

        Spree::Config[:attachment_styles] = ActiveSupport::JSON.encode(styles) unless styles.nil?
      end

      def update_headers(params)
        params[:new_s3_headers].each do |index, header|
          params[:s3_headers][header[:name]] = header[:value] unless header[:value].empty?
        end if params[:new_s3_headers].present?

        headers = params[:s3_headers]

        Spree::Config[:s3_headers] = ActiveSupport::JSON.encode(headers) unless headers.nil?
      end

      def update_paperclip_settings
        Spree::Image.attachment_definitions[:attachment][:styles]        = ActiveSupport::JSON.decode(Spree::Config[:attachment_styles])
        Spree::Image.attachment_definitions[:attachment][:path]          = Spree::Config[:attachment_path]
        Spree::Image.attachment_definitions[:attachment][:default_url]   = Spree::Config[:attachment_default_url]
        Spree::Image.attachment_definitions[:attachment][:default_style] = Spree::Config[:attachment_default_style]

        Spree::Image.supports_s3(:attachment)
        Spree::Taxon.supports_s3(:icon)
      end
    end
  end
end

