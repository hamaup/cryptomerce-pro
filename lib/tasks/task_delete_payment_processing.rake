namespace :task_delete_processing_payment do
  desc 'Change status from processing_payment to payment_failure for orders updated_at before now'
  task change_status_from_processing_to_failure: :environment do
    Order.where('status = ? and updated_at < ?', 8, Time.now).update_all(status: 9)
  end
end
