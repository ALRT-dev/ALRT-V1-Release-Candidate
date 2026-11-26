import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { beforeEach, expect, it, vi } from 'vitest';
import { AIPromptsPage } from '../pages/AIPromptsPage';

const mocks = vi.hoisted(() => ({ registry: vi.fn(), update: vi.fn(), publish: vi.fn(), success: vi.fn(), error: vi.fn(), write: true }));
vi.mock('../api/alertTemplates', () => ({ getAlertTemplates: mocks.registry, saveAlertTemplates: mocks.publish }));
vi.mock('../api/resources', () => ({
  listAIPrompts: async () => [{ id: 'official-info', name: 'Official INFO', content: 'Original prompt', model: 'example', updatedAt: '2026-10-20T00:00:00Z' }],
  updateAIPrompt: mocks.update,
}));
vi.mock('../auth/AuthContext', () => ({ useAuth: () => ({ hasRole: () => mocks.write }) }));
vi.mock('../components/ToastContext', () => ({ useToast: () => ({ notifySuccess: mocks.success, notifyError: mocks.error }) }));

beforeEach(() => {
  vi.clearAllMocks();
  mocks.write = true;
  mocks.registry.mockResolvedValue({ state: { published: null }, sources: [] });
  mocks.update.mockResolvedValue({});
});
const show = () => render(<MemoryRouter><AIPromptsPage /></MemoryRouter>);
const editAndConfirm = async () => {
  await userEvent.click(await screen.findByRole('button', { name: 'Edit' }));
  await userEvent.type(screen.getByLabelText('Content'), ' revised');
  await userEvent.click(screen.getByRole('button', { name: 'Save prompt text' }));
};

it('warns that saved rows can affect current alerts immediately without a published snapshot', async () => {
  show();
  expect(await screen.findByText(/No published agency template snapshot/)).toHaveTextContent(/Saving prompt text may affect current alerts immediately/);
  await editAndConfirm();
  expect(screen.getByText(/Saving "Official INFO" may affect current alerts immediately/)).toHaveTextContent(/does not save a draft/);
  expect(mocks.update).not.toHaveBeenCalled();
  const buttons = screen.getAllByRole('button', { name: 'Save prompt text' });
  await userEvent.click(buttons[buttons.length - 1]);
  await waitFor(() => expect(mocks.update).toHaveBeenCalledWith('official-info', { content: 'Original prompt revised' }));
  expect(mocks.publish).not.toHaveBeenCalled();
});

it('explains that the published agency snapshot is preserved while other features may use saved rows', async () => {
  mocks.registry.mockResolvedValue({ state: { published: { version: 7 } }, sources: [] });
  show();
  expect(await screen.findByText(/Published agency template snapshot v7/)).toHaveTextContent(/Other AI features may read saved prompt rows directly/);
  await editAndConfirm();
  expect(screen.getByText(/Saving "Official INFO" updates the prompt row/)).toHaveTextContent(/Agency alerts keep using published snapshot v7/);
  expect(screen.getByText(/Saving "Official INFO" updates the prompt row/)).toHaveTextContent(/separate preview and publish/);
  expect(mocks.publish).not.toHaveBeenCalled();
});

it('does not promise draft safety when registry lookup fails', async () => {
  mocks.registry.mockRejectedValue(new Error('Unavailable'));
  show();
  expect(await screen.findByText(/Could not verify the agency template publication status/)).toHaveTextContent(/may affect current alerts immediately/);
  await editAndConfirm();
  expect(screen.getByText(/Saving "Official INFO" may affect current alerts immediately/)).toHaveTextContent(/Publication status could not be verified/);
  expect(screen.getByText(/Saving "Official INFO" may affect current alerts immediately/)).toHaveTextContent(/does not save a draft/);
});

it('warns conservatively while publication status is still loading', async () => {
  mocks.registry.mockImplementation(() => new Promise(() => {}));
  show();
  await screen.findByRole('button', { name: 'Edit' });
  expect(screen.getByRole('status')).toHaveTextContent(/may affect current alerts immediately/);
  await editAndConfirm();
  expect(screen.getByText(/Saving "Official INFO" may affect current alerts immediately/)).toHaveTextContent(/could not be verified/);
  expect(mocks.update).not.toHaveBeenCalled();
});

it('does not treat an unexpected registry response as a published snapshot', async () => {
  mocks.registry.mockResolvedValue({ state: {} });
  show();
  expect(await screen.findByText(/Could not verify the agency template publication status/)).toHaveTextContent(/may affect current alerts immediately/);
});

it('refreshes publication status when opening an editor', async () => {
  mocks.registry.mockResolvedValueOnce({ state: { published: { version: 7 } } })
    .mockResolvedValue({ state: { published: null } });
  show();
  await screen.findByText(/Published agency template snapshot v7/);
  await editAndConfirm();
  expect(screen.getByText(/Saving "Official INFO" may affect current alerts immediately/)).toHaveTextContent(/no published agency template snapshot/);
  expect(mocks.registry).toHaveBeenCalledTimes(2);
});

it('keeps viewing available without exposing save controls to a moderator', async () => {
  mocks.write = false;
  show();
  await userEvent.click(await screen.findByRole('button', { name: 'View' }));
  expect(screen.getByLabelText('Content')).toHaveAttribute('readonly');
  expect(screen.queryByRole('button', { name: 'Save prompt text' })).not.toBeInTheDocument();
  expect(mocks.update).not.toHaveBeenCalled();
  expect(mocks.publish).not.toHaveBeenCalled();
});
