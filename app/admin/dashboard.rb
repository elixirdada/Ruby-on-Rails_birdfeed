ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }
  page_action :import_track_info, method: :post do
    # set a breakpoint here to check if you receive the file inside params properly
    # CsvWorker.perform_async(params[:file].path)
    # do anything else you need and redirect as the last step
    TrackInfoSheets::CsvImport.new(params[:file]).call
    redirect_to admin_dashboard_path
  end

  content title: proc{ I18n.t("active_admin.dashboard") } do
    # div class: "blank_slate_container", id: "dashboard_default_message" do
    #   span class: "blank_slate" do
    #     span I18n.t("active_admin.dashboard_welcome.welcome")
    #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #   end
    # end
    if current_user.has_role? :admin
        render 'users' # /app/views/admin/dashboard/_users.html.erb
    end

    columns do
        column id: 'csv_upload_column' do
          panel 'CSV Uploads for Track Info' do
            ul do
              render 'admin/dashboard/import_track_info'
            end
          end
        end
    end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
